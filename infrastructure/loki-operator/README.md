# loki-operator

Loki Operator in global namespace `openshift-operators-redhat`.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-loki-operator` |

```bash
kubectl kustomize infrastructure/loki-operator/overlays/ocp
oc get csv -n openshift-operators-redhat
```

Package owns Namespace + OperatorGroup + Subscription.
