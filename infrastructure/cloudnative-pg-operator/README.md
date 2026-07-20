# cloudnative-pg-operator

CloudNativePG operator (Quay database).

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `infra-cloudnative-pg-operator` |

```bash
kubectl kustomize infrastructure/cloudnative-pg-operator/overlays/ocp
oc get csv -n openshift-operators | grep cloudnative
```
