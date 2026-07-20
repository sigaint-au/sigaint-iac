# loki-operator

Loki Operator in global namespace `openshift-operators-redhat`.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `infra-loki-operator` |
| Channel | `stable-6.6` |

```bash
kubectl kustomize infrastructure/loki-operator/overlays/ocp
oc get csv -n openshift-operators-redhat
```

Package owns Namespace + OperatorGroup + Subscription.
