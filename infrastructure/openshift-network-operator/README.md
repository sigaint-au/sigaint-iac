# openshift-network-operator

GitOps overlay for the cluster `Network` CR (`operator.openshift.io/v1`).

Managed fields (Server-Side Apply):

| Field | Purpose |
|-------|---------|
| `spec.defaultNetwork.ovnKubernetesConfig.mtu` | Cluster network MTU (`8900` for 9k jumbo) |
| `spec.defaultNetwork.ovnKubernetesConfig.gatewayConfig.routingViaHost` | Host routing for multi-homed / MetalLB / Istio ambient |
| `spec.defaultNetwork.ovnKubernetesConfig.gatewayConfig.ipForwarding` | `Global` IP forwarding on the host |

All other `Network` fields remain owned by the Cluster Network Operator (CNO).

## 9k MTU (jumbo frames)

Steady-state target:

| Layer | MTU | Notes |
|-------|-----|--------|
| Machine / NIC | **9000** | Host and switch must support jumbo frames |
| Cluster network (OVN) | **8900** | Machine MTU − 100 (OVN-Kubernetes overhead) |

Permanent OVN MTU is set in `base/network.yaml` as `ovnKubernetesConfig.mtu: 8900`.

Secondary physnet NICs (for example `eno2` via NMState) set host MTU **9000** in
`infrastructure/nmstate/` — see that package README for node labeling
(`sigaint.au/physnet=eno2`).

### Verify

```bash
oc get network.config.openshift.io cluster \
  -o jsonpath='{.status.clusterNetworkMTU}{"\n"}'
# Expect: 8900

oc get network.operator.openshift.io cluster \
  -o jsonpath='{.spec.defaultNetwork.ovnKubernetesConfig.mtu}{"\n"}'
# Expect: 8900
```

### Out of scope

- Secondary Multus NADs under `virtualization/network-attachment-definitions/`
  have their own `mtu` (often 1500); raise those separately if needed on those L2 segments.
