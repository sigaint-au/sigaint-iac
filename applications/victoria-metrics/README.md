# victoria-metrics

VictoriaMetrics single-node (Helm). Namespace: `sigaint-monitoring`.

| | |
|--|--|
| Cluster | `ocp` |
| App | `app-victoria-metrics` |
| LB pool | `dmz-lhm-prod` |

```bash
kubectl kustomize --enable-helm applications/victoria-metrics/overlays/ocp
```

```yaml
# Service annotations (ingest LB)
metallb.io/ip-allocated-from-pool: dmz-lhm-prod
```

Cert DNS: `metrics.sigaint.au`. Chart vendored under `base/charts/`.
