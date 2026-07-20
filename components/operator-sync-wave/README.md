# operator-sync-wave

Argo CD sync-wave annotations for **OLM install** resources.

| Kind | Wave |
|------|------|
| `Namespace` | `-10` |
| `OperatorGroup` | `-5` |
| `CatalogSource` | `-5` |
| `Subscription` | `-1` (+ `SkipDryRunOnMissingResource`) |

```yaml
# package base/kustomization.yaml
components:
  - ../../../components/operator-sync-wave
```
