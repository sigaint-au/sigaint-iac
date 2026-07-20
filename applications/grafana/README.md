# grafana

Grafana (Helm) for cluster dashboards. Namespace: `sigaint-monitoring`.

| | |
|--|--|
| Cluster | `ocp` |
| App | `app-grafana` |
| Depends on | `grafana-operator`, cert-manager, ingress |

```bash
kubectl kustomize --enable-helm applications/grafana/overlays/ocp
```

TLS host patched in overlay (`observe` / cert issuer). Chart vendored under `base/charts/`.
