# openshift-logging-operator

Red Hat OpenShift Logging operator. Stack instance: `applications/openshift-logging`.

| Field | Value |
|-------|-------|
| Clusters | `hub`, `ocp` |
| Channel | `stable-6.6` (pinned with Loki) |

```bash
kubectl kustomize infrastructure/openshift-logging-operator/overlays/ocp
```
