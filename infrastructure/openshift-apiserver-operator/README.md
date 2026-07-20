# openshift-apiserver-operator

API server TLS / configuration overlays.

| Field | Value |
|-------|-------|
| Clusters | `hub`, `ocp` |

```bash
kubectl kustomize infrastructure/openshift-apiserver-operator/overlays/ocp
kubectl kustomize infrastructure/openshift-apiserver-operator/overlays/hub
```
