# Kubernetes Ingress Demo

<!-- markdown-link-check-disable-next-line -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/k8s-Ingress-demo/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![End-to-End status](https://github.com/electrocucaracha/k8s-Ingress-demo/actions/workflows/ci.yml/badge.svg)](https://github.com/electrocucaracha/k8s-Ingress-demo/actions/workflows/ci.yml)

<!-- markdown-link-check-disable-next-line -->

![visitors](https://visitor-badge.laobi.icu/badge?page_id=electrocucaracha.k8s-Ingress-demo)

## Summary

This project demonstrates how to configure and use the [Kubernetes Ingress resource][1].
It showcases two different Ingress Controllers: [NGINX][2] and [Contour][3].
The demo runs on a multi-node Kubernetes cluster deployed using [KinD (Kubernetes in Docker)][4].

![Dashboard](img/diagram.png)

## Virtual Machines

You can use [Vagrant][5] to provision an Ubuntu Focal virtual machine.
To simplify the setup, use the _setup.sh_ script provided by the [bootstrap-vagrant project][6].
This script installs the required Vagrant dependencies and plugins.

It supports two virtualization providers:

- Libvirt
- VirtualBox

Specify the provider using the **PROVIDER** environment variable. For example:

    curl -fsSL http://bit.ly/initVagrant | PROVIDER=libvirt bash

Once Vagrant is ready, provision the virtual machine by running:

    vagrant up

> The setup process may take some time as it installs all dependencies and deploys Kubernetes.

### Environment variables

| Name               | Description                                                |
| :----------------- | :--------------------------------------------------------- |
| DEBUG              | Enable verbose output during the execution.(Boolean value) |
| INGRESS_CONTROLLER | Determine the Ingress Controller to be used.(String value) |

[1]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[2]: https://kubernetes.github.io/ingress-nginx/
[3]: https://projectcontour.io/
[4]: https://kind.sigs.k8s.io/
[5]: https://www.vagrantup.com/
[6]: https://github.com/electrocucaracha/bootstrap-vagrant
