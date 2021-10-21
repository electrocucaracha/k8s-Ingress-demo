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

export PKG_KREW_PLUGINS_LIST=" "

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
