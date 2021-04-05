# RH ACM Deployment and Configuration 🧙

Repo to deploy and configure an RHACM lab

## Installation

There are two ways of install this lab, or step by step or in an automatic deployment using a all-in-one script.

### Automatic Deployment

* [Automatic Deployment](./assets/automaticdeploy.md)

### Step by Step

* [Step by Step Deployment](./assets/stepbystep.md)

## Usage:

After the installation, you will get all the elements of the lab installed using GitOps and Argocd:

<img align="center" width="550" src="acm-deploy-overview.png">

You will have installed the following resources:

* ArgoCD
* Dex (for ArgoCD OAuth integration)
* OAuth Htpasswd Authentication
* OCP RBAC (Users and Groups)
* RHACM Operator
* Sealed Secrets
* RHACM Observability
* Container Security Operator

A quick look of the Operators installed is:

<img align="center" width="550" src="acm-deploy-overview.png">
