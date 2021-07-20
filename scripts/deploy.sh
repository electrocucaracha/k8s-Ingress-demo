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

kubectl apply -f ../deployments/

kubectl rollout status deployment/deployment-es --timeout=3m
kubectl rollout status deployment/deployment-default --timeout=3m

attempt_counter=0
max_attempts=6
until kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -l app.kubernetes.io/component=controller | grep -q "updating Ingress status"; do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
        echo "Max attempts reached"
        exit 1
    fi
    attempt_counter=$((attempt_counter+1))
    sleep $((attempt_counter*10))
done
