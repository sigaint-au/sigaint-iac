# network-attachment-definitions

OVN-Kubernetes **localnet** Multus NADs for the LHM production VLAN layout.
Attached to secondary physnet (`eno2` → `ovs-br1`) via NMState bridge-mappings.

Naming: **`<network>-lhm-prod`**.

## VLAN → NAD

| VLAN | Name     | NAD (`default/…`)   | IPv4           | IPv6                  | Purpose |
|------|----------|---------------------|----------------|-----------------------|---------|
| 10   | MGMT     | `mgmt-lhm-prod`     | 10.120.10.0/24 | 2404:e80:4b6f:10::/64 | Management & monitoring |
| 11   | SECURE   | `secure-lhm-prod`   | 10.120.11.0/24 | 2404:e80:4b6f:11::/64 | Secure workloads |
| 12   | SECURITY | `security-lhm-prod` | 10.120.12.0/24 | 2404:e80:4b6f:12::/64 | Security appliances |
| 13   | USER     | `user-lhm-prod`     | 10.120.13.0/24 | 2404:e80:4b6f:13::/64 | End users / clients |
| 14   | SERVER   | `server-lhm-prod`   | 10.120.14.0/24 | 2404:e80:4b6f:14::/64 | Servers (proxy-arp VIPs) |
| 20   | DMZ      | `dmz-lhm-prod`      | 10.120.20.0/24 | 2404:e80:4b6f:20::/64 | DMZ / public-facing |
| 21   | VMNET    | `vmnet-lhm-prod`    | 10.120.21.0/24 | 2404:e80:4b6f:21::/64 | VMs / internal |

Router on each IPv4/IPv6 segment is typically `.1` / `::1`.

## CNI / OVN notes

- Topology: `localnet` on OVN overlay (`ovn-k8s-cni-overlay`)
- **MTU 9000** (matches `eno2` jumbo physnet)
- CNI `"name"` equals the NAD name and the NMState `ovn.bridge-mappings[].localnet`
- `netAttachDefName`: `default/<name>`

Attach VMs/pods with Multus, for example:

```yaml
interfaces:
  - name: nic-server
    bridge: {}
networks:
  - name: nic-server
    multus:
      networkName: default/server-lhm-prod
```

## Related

- Physnet + bridge-mappings: `infrastructure/nmstate/overlays/ocp/physnet1-external-eno2.yaml`
- Node label: `sigaint.au/physnet=eno2` (see `infrastructure/nmstate/README.md`)
- `dhcp-shim` remains for CNI DHCP IPAM experiments (not VLAN-specific)
