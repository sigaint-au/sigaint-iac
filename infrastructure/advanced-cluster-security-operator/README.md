# advanced-cluster-security-operator

Red Hat Advanced Cluster Security (Central + SecuredCluster).

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-advanced-cluster-security-operator` |
| Depends on | `compliance-operator` (recommended) |

```bash
kubectl kustomize infrastructure/advanced-cluster-security-operator/overlays/ocp
oc get central,securedcluster -A
```
