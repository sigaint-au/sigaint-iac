# quay

Red Hat Quay registry + CloudNativePG database. Namespace: `sigaint-quay`.

| | |
|--|--|
| Cluster | `ocp` |
| App | `app-quay` |
| Depends on | `quay-operator`, `cloudnative-pg-operator`, External Secrets |

```bash
kubectl kustomize applications/quay/overlays/ocp
```

**First deploy:** after OBC/S3 credentials exist, ensure Quay app config secret keys match (see External Secrets / Doppler).

```bash
oc get quayregistry -n sigaint-quay
oc get cluster -n sigaint-quay   # CNPG
```
