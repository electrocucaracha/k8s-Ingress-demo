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
set -o xtrace
set -o errexit
set -o nounset

# Install dependencies
pkgs="httpie"
for pkg in podman kind kubectl make go-lang; do
    if ! command -v "$pkg"; then
        pkgs+=" $pkg"
    fi
done
if [ -n "$pkgs" ]; then
    # NOTE: Shorten link -> https://github.com/electrocucaracha/pkg-mgr_scripts
    curl -fsSL http://bit.ly/install_pkg | PKG=$pkgs bash
fi

if ! sudo kind get clusters | grep -q kind; then
    cat << EOF | sudo kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  kubeProxyMode: "ipvs"
nodes:
  - role: control-plane
    image: kindest/node:v1.19.1
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
  - role: worker
    image: kindest/node:v1.19.1
  - role: worker
    image: kindest/node:v1.19.1
  - role: worker
    image: kindest/node:v1.19.1
EOF
    mkdir -p "$HOME/.kube"
    sudo cp /root/.kube/config "$HOME/.kube/config"
    sudo chown -R "$USER" "$HOME/.kube/"
fi

if [ -z "$(podman images electrocucaracha/web:1.0 -q)" ] && [ ! -f /tmp/web.tgz ]; then
    podman build -t electrocucaracha/web:1.0 .
    podman image prune --force
    podman save --output /tmp/web.tgz --compress electrocucaracha/web:1.0
fi

sudo kind load image-archive /tmp/web.tgz
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

if ! grep -q PORT /etc/environment; then
    echo "export PORT=9001" | sudo tee --append /etc/environment
fi
# http localhost:$PORT
