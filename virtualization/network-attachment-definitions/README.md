# network-attachment-definitions

OVN **localnet** Multus NADs for LHM production VLANs (`*-lhm-prod`).

| VLAN | NAD | IPv4 |
|------|-----|------|
| 10 | `mgmt-lhm-prod` | 10.120.10.0/24 |
| 11 | `secure-lhm-prod` | 10.120.11.0/24 |
| 12 | `security-lhm-prod` | 10.120.12.0/24 |
| 13 | `user-lhm-prod` | 10.120.13.0/24 |
| 14 | `server-lhm-prod` | 10.120.14.0/24 |
| 20 | `dmz-lhm-prod` | 10.120.20.0/24 |
| 21 | `vmnet-lhm-prod` | 10.120.21.0/24 |

MTU **9000**. CNI name = NMState `localnet` on `ovs-br1`.

```yaml
networks:
  - name: nic
    multus:
      networkName: default/server-lhm-prod
```

```bash
kubectl kustomize virtualization/network-attachment-definitions/overlays/ocp
oc get net-attach-def -n default
```
