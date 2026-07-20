# operator-instance-sync-wave

Argo CD sync-wave + `SkipDryRunOnMissingResource` for **operator instances** and helpers (after OLM/CRDs).

| Wave | Examples |
|------|----------|
| `5` | Secret, ExternalSecret, Certificate, LocalVolumeDiscovery |
| `10` | MetalLB, StorageCluster, Central, HyperConverged, … |
| `15+` | IPAddressPool, BGPPeer, SecuredCluster, NNCP, … |

```yaml
components:
  - ../../../components/operator-sync-wave
  - ../../../components/operator-instance-sync-wave
```

Use both when a package installs the operator **and** instance CRs.
