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
  5  Secrets, Certificates, ExternalSecretsConfig, LocalVolumeDiscovery
 10  Primary CRs (ClusterSecretStore, MetalLB, StorageCluster, Central, …)
15+  Dependents (ExternalSecret, IPAddressPool, BGPPeer, NNCP, Kiali, …)
 20  Late dependents (OSSMConsole, QuayRegistry, …)
```
