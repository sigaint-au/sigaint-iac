# node-feature-discovery-operator

Node Feature Discovery (NFD) — labels nodes with CPU, PCI, kernel, and hardware
features for scheduling (OpenShift Virtualization, GPU, device plugins).

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-node-feature-discovery-operator` |
| Channel | `stable` |
| Namespace | `openshift-nfd` |

```bash
kubectl kustomize infrastructure/node-feature-discovery-operator/overlays/ocp
oc get csv -n openshift-nfd
oc get nodefeaturediscovery -n openshift-nfd
oc get nodes -o json | jq -r '.items[].metadata.labels | keys[]' | grep feature.node | sort -u | head
```

## Instance (`NodeFeatureDiscovery` `nfd-instance`)

| Field | Value |
|-------|--------|
| Operand port | `12000` |
| Worker interval | `60s` |
| PCI classes | `0200` (network), `03` (display), `12` (processing accelerators) |
| PCI label fields | `vendor` |

## Notes

- Labels appear as `feature.node.kubernetes.io/*` on nodes after workers reconcile.
- Install early relative to GPU / device-plugin Operators that select on NFD labels.
