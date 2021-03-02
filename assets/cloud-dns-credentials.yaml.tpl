apiVersion: v1
kind: Secret
metadata:
  name: cloud-dns-credentials
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY}"
  AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_KEY}"
  AWS_DNS_SLOWRATE: "1"
