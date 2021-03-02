# RH ACM Deployment and Configuration 🧙‍

Repo to deploy and configure an RHACM lab

## Automatic Deployment

```
./deploy.sh
```

## Step by Step

### 1. Installing ArgoCD

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

### 2. Deploying the ACM Lab Resources

```
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/acm-lab-deploy/config/overlays/default
```

### 3. Apply the Sealed Secrets Key

```
export PRIVATEKEY_SEALED="assets/sealed-tls.key"
export PUBLICKEY_SEALED="assets/sealed-tls.crt"
export NS_SEALED_SEALED="kube-system"
export SECRETNAME_SEALED="sealedkeys"

oc delete secret -n $NS_SEALED_SEALED -l sealedsecrets.bitnami.com/sealed-secrets-key
oc -n "$NS_SEALED_SEALED" create secret tls "$SECRETNAME_SEALED" --cert="$PUBLICKEY_SEALED" --key="$PRIVATEKEY_SEALED"
oc -n "$NS_SEALED_SEALED" label secret "$SECRETNAME_SEALED" sealedsecrets.bitnami.com/sealed-secrets-key=active
sleep 10
```

### 4. Configure the ACM Lab Resources

```
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/acm-lab-config/config/overlays/default
```
