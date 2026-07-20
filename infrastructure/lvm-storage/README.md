# lvm-storage

LVM Storage (Topolvm) for hub local volumes.

| | |
|--|--|
| Cluster | `hub` |
| App | `hub-lvm-storage` |

```bash
kubectl kustomize infrastructure/lvm-storage/overlays/hub
oc get lvmcluster -A
```
