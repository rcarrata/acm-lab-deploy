#!/bin/bash

## Envs
export PRIVATEKEY_SEALED="assets/sealed-tls.key"
export PUBLICKEY_SEALED="assets/sealed-tls.crt"
export NS_SEALED_SEALED="kube-system"
export SECRETNAME_SEALED="sealedkeys"

## ArgoCD Install & Config
echo "## Deploy the ArgoCD infrastructure"
until oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/argocd/install; do sleep 2; done
sleep 60

ARGOCD_ROUTE=$(oc get route argocd-server -n argocd -o jsonpath='{.spec.host}{"\n"}')

while [ `curl -ks -o /dev/null -w "%{http_code}" https://$ARGOCD_ROUTE` != 200 ];do
        echo "waiting for ArgoCD"
        sleep 10
done
        echo "ArgoCD operator"

## Deployment of ACM through ArgoCD
echo "## Deploy the ACM Lab resources"
oc apply -k acm-lab-deploy/config/overlays/default
sleep 60

## Deployment of Sealed Secrets
echo "## Regenerate Sealed Secrets with OWN certificates"
oc delete secret -n $NAMESPACE -l sealedsecrets.bitnami.com/sealed-secrets-key
oc -n "$NAMESPACE" create secret tls "$SECRETNAME" --cert="$PUBLICKEY" --key="$PRIVATEKEY"
oc -n "$NAMESPACE" label secret "$SECRETNAME" sealedsecrets.bitnami.com/sealed-secrets-key=active
oc delete pod $(oc get pod -n kube-system -l name=sealed-secrets-controller | grep sealed-secrets | awk '{ print $1 }')
sleep 10

export AWS_ACCESS_KEY=$(oc get secret aws-creds -n kube-system -o jsonpath='{.data.aws_access_key_id}')
export AWS_SECRET_KEY=$(oc get secret aws-creds -n kube-system -o=jsonpath='{.data.aws_secret_access_key}')
export AWS_ACCESS_KEY_ID=$(echo $AWS_ACCESS_KEY | base64 -d)
export AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_KEY | base64 -d)
export AWS_DEFAULT_REGION=eu-west-1

## Deployment of Observability in ACM
echo "## Deployment of ACM Observability"
export S3_BUCKET="obs-thanos"
aws s3api create-bucket --bucket $S3_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
export S3_ENDPOINT="s3.$AWS_DEFAULT_REGION.amazonaws.com"
envsubst < assets/obs-secret.yaml.tpl > assets/obs-secret.yaml
kubeseal --cert "${PUBLICKEY_SEALED}" -o yaml --scope cluster-wide < assets/obs-secret.yaml > manifests/rhacm-observability/base/obs-secret.yaml
git commit -am "added new obs bucket"
git push

envsubst < assets/cloud-dns-credentials.yaml.tpl > assets/cloud-dns-credentials.yaml
kubeseal --cert "${PUBLICKEY_SEALED}" -o yaml --scope cluster-wide < assets/cloud-dns-credentials.yaml > manifests/letsencrypt-certs/base/cloud-dns-credentials.yaml
git commit -am "added new cloud dns credentials"
git push
sleep 5

# ACM Deploy the Config for ACM
echo "## Deployment and Configuration of ACM instance"
echo "## Enabling full mode"
oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/acm-lab-config/config/overlays/full
