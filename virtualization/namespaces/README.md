# namespaces

Shared namespaces for virtualization and platform workloads.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `virt-namespaces` |

| Namespace | Purpose |
|-----------|---------|
| `lhm-prod-vmnet` | Virtualization / VMNET |
| `lhm-prod-dmz` | Virtualization / DMZ |
| `lhm-prod-monitoring` | Monitoring stack |
| `lhm-prod-quay` | Quay registry |

```bash
kubectl kustomize virtualization/namespaces/overlays/ocp
oc get ns lhm-prod-vmnet lhm-prod-dmz lhm-prod-monitoring lhm-prod-quay
```
