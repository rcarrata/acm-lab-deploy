# RH ACM Deployment and Configuration

Repo to deploy and configure an RHACM lab

### Installing ArgoCD

```
until oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/argocd/install; do sleep 2; done
```
