## Step by Step

### 1. Installing Openshift GitOps:

```
until oc apply -k bootstrap/; do sleep 2; done

oc patch subscriptions.operators.coreos.com/openshift-gitops-operator -n openshift-operators --type='merge' \
--patch '{ "spec": { "config": { "env": [ { "name": "DISABLE_DEX", "value": "false" } ] } } }'

oc patch argocd/openshift-gitops -n openshift-gitops --type='merge' \
--patch='{ "spec": { "dex": { "openShiftOAuth": true } } }'

oc patch ArgoCD/openshift-gitops -n openshift-gitops --type=merge \
-p '{"spec":{"rbac":{"defaultPolicy":"role:admin"}}}'
```

This step will deploy the following resources for the demo:

* ArgoCD-Operator
* ArgoCD-Instance
* Dex (for OCP-OAuth)


To get your argocd route (where you can login)

```
oc get route openshift-gitops-server  -n openshift-gitops -o jsonpath='{.spec.host}{"\n"}'
```

### 2. Deploying the ACM Lab Resources

```
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/acm-lab-deploy/config/overlays/default
```

This step will deploy the following resources for the demo:

* Sealed-secrets
* OAuth (htpass)
* RBAC
* RHACM-Operator

<img align="center" width="550" src="argo-acm-lab-deploy.png">

### 3. Apply the Sealed Secrets Key

For avoid that the Sealed Secrets generates an internal PKI, you need to provide the sealed-tls.crt/key  pairs. Obviously for security purposes the private key is not in this repo :)

Bring your own certs and exported from here:

```
export PRIVATEKEY_SEALED="assets/sealed-tls.key"
export PUBLICKEY_SEALED="assets/sealed-tls.crt"
export NS_SEALED_SECRETS="kube-system"
export SECRETNAME_SEALED="sealedkeys"

oc delete secret -n $NS_SEALED_SECRETS -l sealedsecrets.bitnami.com/sealed-secrets-key
oc -n "$NS_SEALED_SECRETS" create secret tls "$SECRETNAME_SEALED" --cert="$PUBLICKEY_SEALED" --key="$PRIVATEKEY_SEALED"
oc -n "$NS_SEALED_SECRETS" label secret "$SECRETNAME_SEALED" sealedsecrets.bitnami.com/sealed-secrets-key=active
oc delete pod $(oc get pod -n $NS_SEALED_SECRETS -l name=sealed-secrets-controller | grep sealed-secrets | awk '{ print $1 }') -n $NS_SEALED_SECRETS
sleep 20
```

### 4. Set the AWS Cloud Credentials

```
export AWS_ACCESS_KEY=$(oc get secret aws-creds -n kube-system -o jsonpath='{.data.aws_access_key_id}')
export AWS_SECRET_KEY=$(oc get secret aws-creds -n kube-system -o=jsonpath='{.data.aws_secret_access_key}')
```

```
export AWS_ACCESS_KEY_ID=$(echo $AWS_ACCESS_KEY | base64 -d)
export AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_KEY | base64 -d)
```

```
export AWS_DEFAULT_REGION=eu-west-1
```

### 5. Configure the bucket for Observability

Generate the Thanos Bucket for the Observability in RHACM:

```
export S3_BUCKET="obs-thanos-${RANDOM}"
aws s3api create-bucket --bucket $S3_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
export S3_ENDPOINT="s3.$AWS_DEFAULT_REGION.amazonaws.com"
```

NOTE: be careful because sometimes the bucket exists and you need to specify another, or use the AWS creds to access them.

Then add the obs-secret as SealedSecret in the proper manifest folder:

```
envsubst < assets/obs-secret.yaml.tpl > assets/obs-secret.yaml
kubeseal --cert "${PUBLICKEY_SEALED}" -o yaml --scope cluster-wide < assets/obs-secret.yaml > manifests/rhacm-observability/base/obs-secret.yaml
```

Do the changes in the gitOps way:

```
git commit -am "added new obs bucket"
git push
```

### 6. Configure the letsencrypt Certificates

Add the AWS creds into the cloud dns credentials file and sealed with Sealed Secrets:

```
envsubst < assets/cloud-dns-credentials.yaml.tpl > assets/cloud-dns-credentials.yaml
kubeseal --cert "${PUBLICKEY_SEALED}" -o yaml --scope cluster-wide < assets/cloud-dns-credentials.yaml > manifests/letsencrypt-certs/base/cloud-dns-credentials.yaml
```

Do the changes in the gitOps way:

```
git commit -am "added new cloud dns credentials"
git push
```

### 7. Configure the ACM Lab Resources

Select Mode Default or Full, depending on the resources:

#### 7.1 Select Mode Default (only RHACM)

```
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/acm-lab-config/config/overlays/default
```

This step will deploy the following resources for the demo:

* RHACM Instance Deployment

#### 7.2 Select Mode Full

```
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/acm-lab-config/config/overlays/full
```

This step will deploy the following resources for the demo:

* RHACM Instance Deployment
* Container Security Operator
* RHACM Observability

<img align="center" width="550" src="argo-acm-lab-config.png">

<img align="center" width="550" src="argo-acm-lab-results.png">
