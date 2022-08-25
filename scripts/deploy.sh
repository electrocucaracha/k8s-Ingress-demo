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

kubectl apply -f ../deployments/

kubectl rollout status deployment/deployment-es --timeout=3m
kubectl rollout status deployment/deployment-default --timeout=3m

if [[ ${INGRESS_CONTROLLER:-nginx} == "nginx" ]]; then
    attempt_counter=0
    max_attempts=6
    until kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -l app.kubernetes.io/component=controller | grep -q "updating Ingress status"; do
        if [ ${attempt_counter} -eq ${max_attempts} ]; then
            echo "Max attempts reached"
            exit 1
        fi
        attempt_counter=$((attempt_counter + 1))
        sleep $((attempt_counter * 10))
    done
fi
sleep 30
