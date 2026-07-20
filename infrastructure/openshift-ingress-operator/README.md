# openshift-ingress-operator

IngressController / default ingress TLS configuration.

| Field | Value |
|-------|-------|
| Clusters | `hub`, `ocp` |

```bash
kubectl kustomize infrastructure/openshift-ingress-operator/overlays/ocp
oc get ingresscontroller -n openshift-ingress-operator
```
