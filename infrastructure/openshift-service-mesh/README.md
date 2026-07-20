# openshift-service-mesh

OpenShift Service Mesh / Istio (ambient-related resources in overlay).

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-openshift-service-mesh` |

```bash
kubectl kustomize infrastructure/openshift-service-mesh/overlays/ocp
oc get istios -A
```
