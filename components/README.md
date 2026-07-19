# Shared Kustomize components

## `operator-sync-wave`

Applies Argo CD sync waves to **OLM install resources**:

| Kind | Wave | Notes |
|------|------|--------|
| `Namespace` | `-10` | Operator target namespace |
| `OperatorGroup` | `-5` | Before Subscription |
| `CatalogSource` | `-5` | Optional private catalogs |
| `Subscription` | `-1` | Triggers CSV/CRD install |

Also sets `SkipDryRunOnMissingResource=true` on Subscriptions.

```yaml
# In package base/kustomization.yaml
components:
  - ../../../components/operator-sync-wave
```

## `operator-instance-sync-wave`

Applies waves + `SkipDryRunOnMissingResource` to **operator CRs and helpers**
(secrets, ExternalSecrets, MetalLB, StorageCluster, Central, HyperConverged, …).

Typical order after OLM:

| Wave | Resources |
|------|-----------|
| `5` | Secrets, ExternalSecrets, Certificates, LocalVolumeDiscovery |
| `10` | Primary CRs (MetalLB, StorageCluster, Central, …) |
| `15+` | Dependent CRs (pools, peers, SecuredCluster, NNCPs, …) |

```yaml
components:
  - ../../../components/operator-sync-wave
  - ../../../components/operator-instance-sync-wave
```

Use both on packages that install an operator **and** its instance CRs in the same Application.
