## Automatic Deployment (Ongoing)

For the deployment of the demo in the automatic way use the following command:

```
bash deploy.sh
```

NOTE: be aware that this installation uses a sealed-secrets.keys. Please contact the developers of this lab, or regenerate your own for use sealed secrets feature in your lab, and decrypt all the secrets encrupted (cloud-dns, obs-secret, htpass, etc).

TODO: make the script more user friendly with params.
