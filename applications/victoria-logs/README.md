# victoria-logs

VictoriaLogs single-node (Helm). Namespace: `sigaint-monitoring`.

| | |
|--|--|
| Cluster | `ocp` |
| App | `app-victoria-logs` |
| LB pool | `dmz-lhm-prod` |

```bash
kubectl kustomize --enable-helm applications/victoria-logs/overlays/ocp
```

```yaml
# Service annotations (syslog / ingest LB)
metallb.io/ip-allocated-from-pool: dmz-lhm-prod
```

Cert DNS: `observe.sigaint.au`. Chart vendored under `base/charts/`.
