# openshift-machine-config-operator

MachineConfig / node config (e.g. auto-sizing reserved).

| Field | Value |
|-------|-------|
| Clusters | `hub`, `ocp` |

```bash
kubectl kustomize infrastructure/openshift-machine-config-operator/overlays/ocp
oc get mcp
```
