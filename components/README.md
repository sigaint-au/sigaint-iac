# components

Shared Kustomize **components** (not full packages). Include from package `kustomization.yaml`:

```yaml
components:
  - ../../../components/operator-sync-wave
  - ../../../components/operator-instance-sync-wave
```

| Component | Purpose |
|-----------|---------|
| [`operator-sync-wave`](operator-sync-wave/) | OLM install order (Namespace → OG → Subscription) |
| [`operator-instance-sync-wave`](operator-instance-sync-wave/) | Instance CRs after CRDs exist |
| [`server-side-apply`](server-side-apply/) | SSA + RespectIgnoreDifferences annotations |

## Wave summary

```text
-10  Namespace
 -5  OperatorGroup, CatalogSource
 -1  Subscription
  5  Secrets, ExternalSecrets, Certificates, LocalVolumeDiscovery
 10  Primary CRs (MetalLB, StorageCluster, Central, HyperConverged, …)
15+  Dependents (IPAddressPool, BGPPeer, SecuredCluster, NNCP, Kiali, …)
 20  Late dependents (OSSMConsole, QuayRegistry, …)
```
