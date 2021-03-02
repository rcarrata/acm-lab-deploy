## Argocd Instance Details

### Skip Dry Run for new custom resources types

When syncing a custom resource which is not yet known to the cluster skip the dry run for missing
resource types

```
annotations:
      argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource
```

[Skip Dry Run](https://argoproj.github.io/argo-cd/user-guide/sync-options/#skip-dry-run-for-new-custom-resources-types)
