# advanced-cluster-management

Red Hat Advanced Cluster Management (MultiClusterHub) on the hub cluster.

| Field | Value |
|-------|-------|
| Cluster | `hub` |
| App | `hub-advanced-cluster-management` |

```bash
kubectl kustomize infrastructure/advanced-cluster-management/overlays/hub
oc get multiclusterhub -A
```
