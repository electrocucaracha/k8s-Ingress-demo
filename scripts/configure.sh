#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c)
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset
if [[ ${DEBUG:-false} == "true" ]]; then
    set -o xtrace
fi

# shellcheck source=scripts/_common.sh
source _common.sh

function _gen_kind_config {
    local num_worker_nodes=3

    #kube_version="1.23.5"
    #if [ "${INGRESS_CONTROLLER:-nginx}" == "nginx" ]; then
    kube_version=$(curl -sL https://registry.hub.docker.com/v2/repositories/kindest/node/tags | python -c 'import json,sys,re;versions=[obj["name"][1:] for obj in json.load(sys.stdin)["results"] if re.match("^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$",obj["name"])];print("\n".join(versions))' | uniq | sort -rn | head -n 1)
    #fi

    cat <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  kubeProxyMode: "ipvs"
nodes:
  - role: control-plane
    image: kindest/node:v$kube_version
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
EOF

    for ((i = 0; i < num_worker_nodes; i++)); do
        cat <<EOF
  - role: worker
    image: kindest/node:v$kube_version
EOF
    done
}

trap get_status ERR

# NOTE: this env var is used by kind and ko tools
export KIND_CLUSTER_NAME=k8s

# Provision a K8s cluster
if ! sudo "$(command -v kind)" get clusters | grep -e "$KIND_CLUSTER_NAME"; then
    _gen_kind_config | sudo -E kind create cluster --config=-
    mkdir -p "$HOME/.kube"
    sudo chown -R "$USER": "$HOME/.kube"
    sudo -E kind get kubeconfig | tee "$HOME/.kube/config"
fi

# Wait for node readiness
for node in $(kubectl get node -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
    kubectl wait --for=condition=ready "node/$node" --timeout=3m
done

# Deploy Ingress services
kubectl apply -f "${INGRESS_CONTROLLER:-nginx}.yaml"
case ${INGRESS_CONTROLLER:-nginx} in
nginx)
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    ;;
contour)
    kubectl patch daemonsets -n projectcontour envoy \
        -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
    for resource in $(kubectl get deployment,daemonset -n projectcontour --no-headers | awk '{ print $1}'); do
        kubectl rollout status --namespace projectcontour "$resource" --timeout=3m
    done
    ;;
esac
