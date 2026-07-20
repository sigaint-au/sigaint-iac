# metallb-operator

MetalLB (BGP) LoadBalancer VIPs for LHM production VLANs.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-metallb-operator` |
| Peer | `10.120.14.1` (SERVER), ASN 65000 |

## Pools

| Pool | IPv4 VIP range |
|------|----------------|
| `mgmt-lhm-prod` | 10.120.10.200–250 |
| `secure-lhm-prod` | 10.120.11.200–250 |
| `security-lhm-prod` | 10.120.12.200–250 |
| `user-lhm-prod` | 10.120.13.200–250 |
| `server-lhm-prod` | 10.120.14.200–250 |
| `dmz-lhm-prod` | 10.120.20.200–250 |
| `vmnet-lhm-prod` | 10.120.21.200–250 |

`autoAssign: false` — pin services:

```yaml
metallb.io/ip-allocated-from-pool: dmz-lhm-prod
```

```bash
kubectl kustomize infrastructure/metallb-operator/overlays/ocp
oc get ipaddresspool,bgppeer,bgpadvertisement -n metallb-system
```
