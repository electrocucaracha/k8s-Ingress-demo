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

# info() - Prints a info message into the log console
function info {
    _print_msg "INFO" "$1"
}

# error() - Prints a error message into the log console
function error {
    get_status
    _print_msg "ERROR" "$1"
    exit 1
}

function _print_msg {
    echo "$(date +%H:%M:%S) - $1: $2"
}

# get_status() - Print the current status of the cluster
function get_status {
    set +o xtrace
    printf "CPU usage: "
    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage " %"}'
    printf "Memory free(Kb):"
    awk -v low="$(grep low /proc/zoneinfo | awk '{k+=$2}END{print k}')" '{a[$1]=$2}  END{ print a["MemFree:"]+a["Active(file):"]+a["Inactive(file):"]+a["SReclaimable:"]-(12*low);}' /proc/meminfo
    if [[ ${INGRESS_CONTROLLER:-nginx} == "nginx" ]]; then
        echo "Kubernetes Events (ingress-nginx):"
        kubectl get events -n ingress-nginx --sort-by=".metadata.managedFields[0].time"
        echo "Kubernetes Resources (ingress-nginx):"
        kubectl get all -n ingress-nginx -o wide
        echo "NGINX controller logs:"
        kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -l app.kubernetes.io/component=controller
    fi
    echo "Kubernetes Resources:"
    kubectl get all -A -o wide
    echo "Kubernetes Nodes:"
    kubectl describe nodes
}
