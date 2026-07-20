# namespaces

Shared namespaces for virtualization and platform workloads.

| | |
|--|--|
| Cluster | `ocp` |
| App | `virt-namespaces` |

| Namespace | Purpose |
|-----------|---------|
| `lhm-prod-vmnet` | Virtualization / VMNET |
| `lhm-prod-dmz` | Virtualization / DMZ |
| `sigaint-monitoring` | Monitoring stack |
| `sigaint-quay` | Quay registry |

```bash
kubectl kustomize virtualization/namespaces/overlays/ocp
oc get ns lhm-prod-vmnet lhm-prod-dmz
```
