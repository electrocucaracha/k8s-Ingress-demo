# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2020
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

run-local:
	go run demo/main.go
run-docker:
	docker run -p $$PORT:3000 --hostname container electrocucaracha/web:1.0
run-k8s:
	kubectl apply -f deployments/
	kubectl rollout status deployment deployment-es
	kubectl rollout status deployment deployment-default
