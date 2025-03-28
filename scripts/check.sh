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

function assert_contains {
    local input=$1
    local expected=$2

    if ! echo "$input" | grep -q "$expected"; then
        error "Got $input expected $expected"
    fi
}

function assert_non_empty {
    local input=$1

    if [ -z "$input" ]; then
        error "Empty input value"
    fi
}

trap "kubectl delete -f ../deployments" EXIT

# Get ClusterIP for every service
default_clusterip=$(kubectl get svc service-default -o jsonpath='{.spec.clusterIP}')
es_clusterip=$(kubectl get svc service-es -o jsonpath='{.spec.clusterIP}')

# Run Assertions
assert_non_empty "$default_clusterip"
assert_non_empty "$es_clusterip"
assert_contains "$(sudo docker exec k8s-control-plane curl -s "$default_clusterip:9001")" "Hello"
assert_contains "$(sudo docker exec k8s-control-plane curl -s "$es_clusterip:9001")" "Hola"
assert_contains "$(curl -s "http://$(ip route get 8.8.8.8 | grep "^8." | awk '{ print $7 }')/en")" "Hello"
assert_contains "$(curl -s "http://$(ip route get 8.8.8.8 | grep "^8." | awk '{ print $7 }')/es")" "Hola"
