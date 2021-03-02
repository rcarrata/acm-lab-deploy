apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: ${S3_BUCKET}
      endpoint: ${S3_ENDPOINT}
      insecure: false
      access_key: ${AWS_ACCESS_KEY}
      secret_key: ${AWS_SECRET_KEY}
