# quay

Red Hat Quay registry + CloudNativePG database.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `app-quay` |
| Namespace | `lhm-prod-quay` |
| Depends on | `quay-operator`, `cloudnative-pg-operator`, External Secrets |

```bash
kubectl kustomize applications/quay/overlays/ocp
oc get quayregistry -n lhm-prod-quay
oc get cluster -n lhm-prod-quay
```

**First deploy:** after OBC/S3 credentials exist, ensure Quay app config secret keys match (Doppler / External Secrets).
