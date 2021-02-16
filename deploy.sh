#!/bin/bash

export PRIVATEKEY_SEALED="assets/sealed-tls.key"
export PUBLICKEY_SEALED="assets/sealed-tls.crt"
export NS_SEALED_SEALED="kube-system"
export SECRETNAME_SEALED="sealedkeys"

## Deploy the ArgoCD infrastructure
until oc apply -k https://github.com/ocp-tigers/acm-lab-deploy/argocd/install; do sleep 2; done
sleep 30

## Deploy the ACM Lab resources
oc apply -k acm-lab-deploy/config/overlays/default
sleep 60

## Regenerate Sealed Secrets with OWN certificates
oc delete secret -n $NAMESPACE -l sealedsecrets.bitnami.com/sealed-secrets-key
oc -n "$NAMESPACE" create secret tls "$SECRETNAME" --cert="$PUBLICKEY" --key="$PRIVATEKEY"
oc -n "$NAMESPACE" label secret "$SECRETNAME" sealedsecrets.bitnami.com/sealed-secrets-key=active
sleep 10

## Configure the ACM Lab
oc apply -k acm-lab-config/config/overlays/default
