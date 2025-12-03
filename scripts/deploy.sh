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

function _print_stats {
    get_status
    echo "Kubernetes Events (default):"
    kubectl get events --sort-by=".metadata.managedFields[0].time"
    echo "Kubernetes Resources (default):"
    kubectl get all -o wide
}

trap _print_stats ERR

newgrp docker <<EONG
# shellcheck disable=SC1091
[ -f /etc/profile.d/path.sh ] && source /etc/profile.d/path.sh
pushd .. >/dev/null
KIND_CLUSTER_NAME=k8s KO_DOCKER_REPO=kind.local ~/go/bin/ko apply -f deployments/website.yml
popd >/dev/null
EONG

kubectl rollout status deployment/deployment-es --timeout=3m
kubectl rollout status deployment/deployment-default --timeout=3m
