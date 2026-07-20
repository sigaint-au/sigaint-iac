# nmstate

NMState operator and `NodeNetworkConfigurationPolicy` (NNCP) overlays for secondary
physical networking (OVN localnet bridges used by virtualization).

## Node labels

NNCPs select nodes by label. Apply **exactly one** physnet label per node so the
correct NIC is bridged.

| Label | Meaning |
|-------|---------|
| `sigaint.au/physnet=eno2` | Secondary physnet on interface **eno2** (active OCP policy) |
| `sigaint.au/physnet=eno4` | Secondary physnet on interface **eno4** (legacy / optional) |

Optional hardware labels (for policies that match on vendor):

| Label | Example |
|-------|---------|
| `sigaint.au/hardware` | `dell` or `lenovo` |

### Label nodes for eno2 (recommended)

Nodes that should run the `physnet1-external-eno2` policy:

```bash
# Single node
oc label node <node-name> sigaint.au/physnet=eno2

# Several workers
oc label node worker-0 worker-1 worker-2 sigaint.au/physnet=eno2

# Replace a previous physnet value
oc label node <node-name> sigaint.au/physnet=eno2 --overwrite
```

Verify selection:

```bash
oc get nodes -l sigaint.au/physnet=eno2
oc get nncp physnet1-external-eno2
oc get nnce -l nmstate.io/policy=physnet1-external-eno2
```

Remove the label if a node should no longer be configured:

```bash
oc label node <node-name> sigaint.au/physnet-
```

## Active OCP policy: eno2

`overlays/ocp/physnet1-external-eno2.yaml` applies when
`nodeSelector: sigaint.au/physnet: eno2`:

| Setting | Value |
|---------|--------|
| Ethernet | `eno2`, **MTU 9000** (9k jumbo) |
| OVS bridge | `ovs-br1` with port `eno2` |
| OVN localnets | `net-sigaint-corp`, `net-sigaint-dmz`, `net-sigaint-vmnet` |

Underlay switches and the NIC must support jumbo frames. Cluster/OVN overlay MTU
is managed separately under `infrastructure/openshift-network-operator/`
(`mtu: 8900` = 9000 − OVN overhead).

## Policy ↔ label rule

Whatever you set on the NNCP `nodeSelector` must match labels on the node. Do not
apply both `eno2` and `eno4` physnet labels on the same node unless you have
separate policies that intentionally target different interfaces.
