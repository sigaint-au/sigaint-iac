# namespaces

Shared namespaces for virtualization / platform workloads.

| | |
|--|--|
| Cluster | `ocp` |
| App | `virt-namespaces` |

```text
sigaint-vmnet  sigaint-dmz  sigaint-monitoring  sigaint-quay
```

```bash
kubectl kustomize virtualization/namespaces/overlays/ocp
```
