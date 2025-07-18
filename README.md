# Homelab

This repository contains the deployments in my homelab. This document will describe the details of my compute cluster and the structure of this repository in terms of the folders, and the individual folders will have more details about each deployment.

## Cluster hardware

My homelab is composed of 3 mini computers, 1 Raspberry Pi 3B+ and 1 unmanaged 5 port TP-Link switch.

### Mini computers

1. Lenovo ThinkCenter M910q - i5-6500T @ 2.5GHz, 32GB DDR4 RAM, 120GB NVMe SSD, 250GB SATA SSD
2. Dell OptiPlex 5050 - i5-6500T @ 2.5GHz, 16GB DDR4 RAM, 120GB NVMe SSD, 250GB SATA SSD
3. Dell OptiPlex 5050 - i5-6500T @ 2.5GHz, 16GB DDR4 RAM, 120GB NVMe SSD, 2TB SATA HDD

### Raspberry Pi

1. Raspberry Pi 3B+ - ARM Cortex A53 @ 1.4GHz, 1GB RAM, 16GB MicroSD

### Switch

1. Unmanaged 5-port TP-Link TL-SG105 switch

## Software setup

- The mini computers all run Proxmox VE 8.4.1 configured in a HA cluster
- The 250GB SATA SSDs and the 2TB SATA HDD are in a Ceph cluster storage
- The Raspberry Pi 3B+ runs OpenWrt 24.10.0-rc1 to connect to my (rented apartment's) WiFi and then bridge the connection over to a LAN which connects to my main computer (Macbook Air M1 - 16GB RAM, 256GB storage)
- 1 node in the cluster runs a PiHole container for DNS and ad-blocking
- Tailscale is set up on 1 node and Tailscale DNS server is configured to PiHole for remote access and adblocking; other nodes use PiHole for DNS
- Kubernetes setup with kubeadm across 1 master node Ubuntu Server VM and 3 worker node Ubuntu Server VMs (1 on each node in cluster) running Flannel, LocalPathProvisioner from Rancher, MetalLB, Ingress-NGINX, CloudNativePG and Minio (more details in kubernetes/README.md and kubernetes-helm/README.md)

## Project folders structure

- kubernetes/ - This contains the Kubernetes deployments that can be applied with kubectl apply
- kubernetes-helm/ - This contains the entire platform as a Helm chart with the deployments templatized from kubernetes/

Both of these are WIPs

## TODO

1. Integrate CI/CD processes to make rollouts easier
2. Explore IaC (TerraForm, Pulumi etc.) to provision VMs in code
