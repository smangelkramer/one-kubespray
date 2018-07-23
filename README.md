# one-kubespray

PoC for deploying a Kubernetes cluster with Docker, Terraform and Ansible on OpenNebula

## Intro

This is a "proof of concept" for deploying a (production grade) Kubernetes Cluster
on OpenNebula. This PoC is based on

- Docker
- Terraform
- Runtastic Terraform Provider for OpenNebula
- Ansible
- Kubespray

Warning: This is no "production" code - it`s an PoC.

The whole ecosystem is contained in a Docker Container.

## Building the Docker Container

First clone the repository to your Docker host:

    $ git clone https://github.com/smangelkramer/one-kubespray.git
    
Now build the Docker Image:

    $ docker build -t mykubernetescluster .
    
This builds the a Docker image with all needed tools. This process creates the following steps for you:

- Docker Image from a clean Alpine 3.8 Linux
- Installs Terraform
- Installs the Runtastic Terraform Provider for OpenNebula
- Clones the current "kubespray" Git-Repository inside the Image
- Creates an SSH Keypair for the deployment of the Kubernetes Nodes (SSH / Ansible)
- Offers you a shell for deploying your Cluster

## Requirement on your OpenNebula Cloud

- Ubuntu 16.04 Image with Contextualization
- IP-Network which has to be accessible from your Docker Host
- Connectivity to ONE XMLRPC (https://your.cloud.com:2633/RPC2)

The rest is done by Terraform (VM-Template, VMs)

## Deployment of a Kubernetes Cluster

### OpenNebula Credentials

Set your OpenNebula crdentials in `code/terraform/variables.tf`:

    variable "endpoint_url" { default = "https://your.cloud.com:2633/RPC2" }
    variable "one_username" { default = "username" }
    variable "one_password" { default = "password" }

### OpenNebula VM Template for Terraform

Check the OpenNebula template in `code/terraform/opennebula_kubernetes_template.tmpl` 
and set / point to your OpenNebula ressources:

- `IMAGE_ID`= ID of your Ubuntu 16.04 Image with Contextualization
- `NETWORK`= Name of your network in OpenNebula
- `NETWORK_UNAME`= Username for your network

        CONTEXT = [
          NETWORK = "YES",
          SSH_PUBLIC_KEY = "${file("/code/id_rsa_kubespray.pub")}",
          SET_HOSTNAME="$$NAME",
          USERNAME = "root",
          START_SCRIPT_BASE64 = "c3dhcG9mZiAtYQ=="
        ]
        CPU = "0.25"
        VCPU = "6"
        DISK = [
          IMAGE_ID = "71" ]
        GRAPHICS = [
          LISTEN = "0.0.0.0",
          TYPE = "VNC" ]
        INPUTS_ORDER = ""
        MEMORY = "5000"
        MEMORY_UNIT_COST = "MB"
        NIC = [
          NETWORK = "NET-NAME",
          NETWORK_UNAME = "user" ]
        OS = [
          ARCH = "x86_64",
          BOOT = "" ]



### Start the Image and provision your Kubernets Cluster

    $ docker run -it -v /path/to/one-kubespray/Docker/code/terraform:/code/terraform mykubernetescluster /bin/bash
    
    $ cd terraform
    
    $ terraform init
    $ terraform apply
    
    
This builds 3 VMs in your OpenNebula Cloud and provsions a Kubernetes Cluster with Kubespray on them. You are completely free to customize this provisioning for your infrastructrure. For me it`s just a small PoC :-)
