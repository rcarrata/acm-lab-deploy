# RH ACM Deployment and Configuration

Repo to deploy and configure an RHACM lab

### Installing ArgoCD

```
until oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/argocd/install; do sleep 2; done
```

This will start the installation of argocd. You can monitor the install with a watch on the following command.

```
oc get pods -n argocd
```

To get your argocd route (where you can login)

```
oc get route argocd-server -n argocd -o jsonpath='{.spec.host}{"\n"}'
```

### Deploying the Resources for the RH Demo

```
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/cluster-config/config/overlays/default
```
