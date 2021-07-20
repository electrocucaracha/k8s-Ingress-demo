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

function info {
    _print_msg "INFO" "$1"
}

function error {
    set +o xtrace
    _print_msg "ERROR" "$1"
    printf "CPU usage: "
    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage " %"}'
    printf "Memory free(Kb):"
    awk -v low="$(grep low /proc/zoneinfo | awk '{k+=$2}END{print k}')" '{a[$1]=$2}  END{ print a["MemFree:"]+a["Active(file):"]+a["Inactive(file):"]+a["SReclaimable:"]-(12*low);}' /proc/meminfo
    if command -v kubectl; then
        echo "Kubernetes Events:"
        kubectl get events -A --sort-by=".metadata.managedFields[0].time"
        echo "Kubernetes Resources:"
        kubectl get all -A -o wide
        echo "Kubernetes Pods:"
        kubectl describe pods
        echo "Kubernetes Nodes:"
        kubectl describe nodes
    fi
    exit 1
}

function _print_msg {
    echo "$(date +%H:%M:%S) - $1: $2"
}

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
assert_contains "$(sudo docker exec kind-worker curl -s "$default_clusterip:9001")" "Hello"
assert_contains "$(sudo docker exec kind-worker curl -s "$es_clusterip:9001")" "Hola"
assert_contains "$(curl -s http://localhost/en)" "Hello"
assert_contains "$(curl -s http://localhost/es)" "Hola"
