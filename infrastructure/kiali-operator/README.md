# kiali-operator

Kiali Operator (`kiali-ossm`) + Kiali CR + OpenShift console plugin (`OSSMConsole`).

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-kiali-operator` |
| Depends on | `openshift-service-mesh` (ApplicationSet wave `0` → kiali `5`) |

```bash
kubectl kustomize infrastructure/kiali-operator/overlays/ocp
oc get csv -n openshift-operators | grep kiali
oc get kiali -A
oc get ossmconsole -n openshift-operators
```

| Resource | Wave | Notes |
|----------|------|--------|
| Subscription | `-1` | Installs CRDs for `Kiali` + `OSSMConsole` |
| `Kiali` | `15` | `SkipDryRunOnMissingResource` |
| `OSSMConsole` | `20` | Console plugin; waits for CRD after CSV |
