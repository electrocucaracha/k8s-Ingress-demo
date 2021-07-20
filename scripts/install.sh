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
    export PKG_DEBUG=true
fi

# Install dependencies
pkgs=""
for pkg in docker kind kubectl make; do
    if ! command -v "$pkg"; then
        pkgs+=" $pkg"
    fi
done
if ! command -v go; then
    pkgs+=" go-lang"
fi
if ! command -v http; then
    pkgs+=" httpie"
fi
if [ -n "$pkgs" ]; then
    # NOTE: Shorten link -> https://github.com/electrocucaracha/pkg-mgr_scripts
    curl -fsSL http://bit.ly/install_pkg | PKG=$pkgs bash
fi

# Provision a K8s cluster
if ! sudo kind get clusters | grep -q kind; then
    sudo kind create cluster --config=kind-config.yml
    mkdir -p "$HOME/.kube"
    sudo cp /root/.kube/config "$HOME/.kube/config"
    sudo chown -R "$USER" "$HOME/.kube/"
fi

# Build demo website image
if [ -z "$(sudo docker images electrocucaracha/web:1.0 -q)" ]; then
    pushd ..
    sudo docker build -t electrocucaracha/web:1.0 .
    sudo docker image prune --force
    popd
fi
sudo kind load docker-image electrocucaracha/web:1.0

# Deploy Ingress services
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s