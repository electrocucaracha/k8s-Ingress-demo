# Kubernetes Ingress Demo

<!-- markdown-link-check-disable-next-line -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/k8s-Ingress-demo/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![End-to-End status](https://github.com/electrocucaracha/k8s-Ingress-demo/actions/workflows/ci.yml/badge.svg)](https://github.com/electrocucaracha/k8s-Ingress-demo/actions/workflows/ci.yml)

<!-- markdown-link-check-disable-next-line -->

![visitors](https://visitor-badge.laobi.icu/badge?page_id=electrocucaracha.k8s-Ingress-demo)

## Overview

This project is a didactic demonstration of how to configure and use the Kubernetes Ingress resource.
It compares two different Ingress Controllers:

- [Ingress-Nginx Controller][2]
- [Contour][3]

The demo runs on a multi-node Kubernetes cluster deployed with [KinD][4] (Kubernetes in Docker).
Its primary goal is to provide a simple and reproducible environment for learning, testing, and experimenting
with Ingress behavior across different providers.The demo runs on a multi-node Kubernetes cluster deployed
with KinD (Kubernetes in Docker)

![Architecture](img/diagram.png)

## Virtual Machines Setup

The project can be executed inside a virtual machine provisioned with [Vagrant][5].
An Ubuntu Focal environment is recommended.

To simplify the setup, the setup.sh script from the [bootstrap-vagrant project][6] can be used.
This script installs all required Vagrant dependencies and plugins automatically.

### Supported virtualization providers

The following providers are supported:

- Libvirt
- VirtualBox

Select the provider by setting the **PROVIDER** environment variable. For example:

    curl -fsSL http://bit.ly/initVagrant | PROVIDER=libvirt bash

Once the environment is prepared, provision the virtual machine by running:

    vagrant up

> Note: The provisioning process may take several minutes, as it installs dependencies and deploys the Kubernetes cluster.

## Configuration

### Environment variables

The behavior of the demo can be customized using the following environment variables:

| Name               | Description                                                      |
| :----------------- | :--------------------------------------------------------------- |
| DEBUG              | Enable verbose output during execution (Boolean).                |
| INGRESS_CONTROLLER | Select the Ingress Controller to use (String: nginx or contour). |

[1]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[2]: https://kubernetes.github.io/ingress-nginx/
[3]: https://projectcontour.io/
[4]: https://kind.sigs.k8s.io/
[5]: https://www.vagrantup.com/
[6]: https://github.com/electrocucaracha/bootstrap-vagrant
