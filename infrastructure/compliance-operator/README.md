# compliance-operator

Compliance Operator for OpenShift.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-compliance-operator` |

```bash
kubectl kustomize infrastructure/compliance-operator/overlays/ocp
oc get compliancecheckresults -A | head
```
