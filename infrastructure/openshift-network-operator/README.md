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
| Machine / primary NIC | **9000** | Host/switch must support jumbo frames |
| Cluster network (OVN) | **8900** | Machine MTU − 100 (OVN-Kubernetes overhead) |

The permanent OVN value is set in `base/network.yaml` as `ovnKubernetesConfig.mtu: 8900`.

### Prerequisites

- Underlay (NICs, bonds, switches) supports and is configured for MTU **9000**
- Cluster and operators are healthy before migration
- Confirm current values before changing:

```bash
# Current cluster network MTU (use as migration "from")
oc get network.config.openshift.io cluster \
  -o jsonpath='{.status.clusterNetworkMTU}{"\n"}'

# Current CNO / OVN config
oc get network.operator.openshift.io cluster -o yaml
```

### Day-2 migration (existing clusters)

MTU change is a **two-step** CNO procedure. Do **not** commit `spec.migration` to this repo — Argo would keep re-applying it.

**1. Start migration** (replace `from` with the live `clusterNetworkMTU`):

```bash
oc patch Network.operator.openshift.io cluster --type=merge --patch \
'{"spec": { "migration": { "mtu": { "network": { "from": 1400, "to": 8900 } , "machine": { "to" : 9000} } } } }'
```

Example above assumes current overlay MTU is `1400` (typical when machine MTU is 1500). Adjust `from` if different.

MCO will roll nodes. Wait until machine config pools are updated:

```bash
oc get mcp
# All pools: UPDATED=True, UPDATING=False, DEGRADED=False
```

**2. Finalize** — clear migration and pin the permanent OVN MTU (already in Git once this package is synced):

```bash
oc patch Network.operator.openshift.io cluster --type=merge --patch \
'{"spec": { "migration": null, "defaultNetwork": { "ovnKubernetesConfig": { "mtu": 8900 } } } }'
```

If Argo CD already owns `ovnKubernetesConfig.mtu` via this package, ensure the app is **Synced** after step 1 completes; you may only need:

```bash
oc patch Network.operator.openshift.io cluster --type=json -p \
'[{"op": "remove", "path": "/spec/migration"}]'
```

**3. Verify**

```bash
oc get network.config.openshift.io cluster \
  -o jsonpath='{.status.clusterNetworkMTU}{"\n"}'
# Expect: 8900

oc get network.operator.openshift.io cluster \
  -o jsonpath='{.spec.defaultNetwork.ovnKubernetesConfig.mtu}{"\n"}'
# Expect: 8900

oc get network.operator.openshift.io cluster \
  -o jsonpath='{.spec.migration}{"\n"}'
# Expect empty / null
```

### New installs

Prefer setting machine MTU **9000** in `install-config.yaml` (or DHCP/kernel) at install time so CNO never needs a day-2 migration. This package then only enforces the OVN side (`mtu: 8900`).

### Out of scope

- Secondary Multus NADs under `virtualization/network-attachment-definitions/` still use their own `mtu` (often 1500) — raise those separately if jumbo is required on those L2 segments.
- NMState NNCPs for extra NICs must set interface MTU independently if those links need jumbo frames.
