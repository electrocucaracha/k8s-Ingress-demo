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
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -o xtrace
fi

# shellcheck source=scripts/_common.sh
source _common.sh

trap get_status ERR

# Provision a K8s cluster
if ! sudo "$(command -v kind)" get clusters | grep -e k8s; then
    newgrp docker <<EONG
    kind create cluster --config=kind-config.yml
EONG
fi

# Build demo website image
if [ -z "$(sudo docker images electrocucaracha/web:1.0 -q)" ]; then
    pushd ..
    sudo docker build -t electrocucaracha/web:1.0 .
    sudo docker image prune --force
    popd
fi
sudo kind load docker-image electrocucaracha/web:1.0

# Wait for node readiness
for node in $(kubectl get node -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
    kubectl wait --for=condition=ready "node/$node" --timeout=3m
done

# Deploy Ingress services
kubectl apply -f deploy.yaml
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
