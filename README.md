# Kubernetes Ingress Demo
[![Build Status](https://travis-ci.org/electrocucaracha/k8s-Ingress-demo.png)](https://travis-ci.org/electrocucaracha/k8s-Ingress-demo)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Summary

This project was created to demonstrate how to configure and use the
[Kubernetes Ingress resource][1]. This demo uses [NGINX][2] as Ingress
Controller and the [KinD tool][3] for deploying a multinode Kubernetes
cluster.

## Virtual Machines

The [Vagrant tool][6] can be used for provisioning a CentOS Virtual
Machine. It's highly recommended to use the  *setup.sh* script of the
[bootstrap-vagrant project][7] for installing Vagrant
dependencies and plugins required for this project. That script
supports two Virtualization providers (Libvirt and VirtualBox) which
are determine by the **PROVIDER** environment variable.

    $ curl -fsSL http://bit.ly/initVagrant | PROVIDER=libvirt bash

Once Vagrant is installed, it's possible to provision a Virtual
Machine using the following instructions:

    $ vagrant up

The provisioning process will take some time to install all
dependencies required by this project and perform a Kubernetes
deployment on it.

[1]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[2]: https://kubernetes.github.io/ingress-nginx/
[3]: https://kind.sigs.k8s.io/
[6]: https://www.vagrantup.com/
[7]: https://github.com/electrocucaracha/bootstrap-vagrant
