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

if ! sudo kind get clusters | grep -q kind; then
    sudo kind create cluster --config=kind-config.yml
    mkdir -p "$HOME/.kube"
    sudo cp /root/.kube/config "$HOME/.kube/config"
    sudo chown -R "$USER" "$HOME/.kube/"
fi

if [ -z "$(sudo docker images electrocucaracha/web:1.0 -q)" ]; then
    sudo docker build -t electrocucaracha/web:1.0 .
    sudo docker image prune --force
fi

sudo kind load docker-image electrocucaracha/web:1.0
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

if ! grep -q PORT /etc/environment; then
    echo "export PORT=9001" | sudo tee --append /etc/environment
fi
# http localhost:$PORT
