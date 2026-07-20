# virtualization-operator

OpenShift Virtualization (CNV) + HyperConverged.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-virtualization-operator` |

```bash
kubectl kustomize infrastructure/virtualization-operator/overlays/ocp
oc get hyperconverged -n openshift-cnv
```
