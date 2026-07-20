# openshift-cert-manager-operator

cert-manager (Red Hat) for certificates / issuers.

| | |
|--|--|
| Clusters | `hub`, `ocp` |

```bash
kubectl kustomize infrastructure/openshift-cert-manager-operator/overlays/ocp
oc get certificate -A | head
```
