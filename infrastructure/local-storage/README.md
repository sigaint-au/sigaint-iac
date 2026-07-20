# local-storage

Local Storage Operator + LocalVolumeSet (`local-block`) for ODF OSDs.

| | |
|--|--|
| Cluster | `ocp` (hub has LSO overlays historically) |
| App | `infra-local-storage` |

```bash
kubectl kustomize infrastructure/local-storage/overlays/ocp
oc get localvolumeset,pv -A | head
```
