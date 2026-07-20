# openshift-network-operator

Cluster Network Operator (`Network` CR) — OVN gateway + cluster MTU.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-openshift-network-operator` |

| Field | Value |
|-------|--------|
| OVN MTU | `8900` (9k machine − 100) |
| `routingViaHost` | `true` |
| `ipForwarding` | `Global` |

```bash
kubectl kustomize infrastructure/openshift-network-operator/overlays/ocp
oc get network.operator cluster   -o jsonpath='{.spec.defaultNetwork.ovnKubernetesConfig.mtu}{"\n"}'
```

Secondary NIC MTU: `infrastructure/nmstate/`.
