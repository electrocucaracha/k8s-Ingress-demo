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

last_version=$(curl -sL https://registry.hub.docker.com/v1/repositories/kindest/node/tags | python -c 'import json,sys;versions=[obj["name"][1:] for obj in json.load(sys.stdin) if obj["name"][0] == "v"];print("\n".join(versions))' | sort -rn | head -n 1)

cat << EOT > scripts/kind-config.yml
---
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2021
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  kubeProxyMode: "ipvs"
nodes:
  - role: control-plane
    image: kindest/node:v$last_version
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
    image: kindest/node:v$last_version
  - role: worker
    image: kindest/node:v$last_version
  - role: worker
    image: kindest/node:v$last_version
EOT
