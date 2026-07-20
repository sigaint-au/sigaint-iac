# kube-descheduler-operator

Kube Descheduler Operator — rebalances pods (including OpenShift Virtualization
workloads) when soft topology or utilization policies are violated.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-kube-descheduler-operator` |
| Channel | `stable` |
| Namespace | `openshift-kube-descheduler-operator` |
| Depends on | `virtualization-operator` (ApplicationSet wave) |

```bash
kubectl kustomize infrastructure/kube-descheduler-operator/overlays/ocp
oc get csv -n openshift-kube-descheduler-operator
oc get kubedescheduler cluster -n openshift-kube-descheduler-operator -o yaml
```

## Instance (`KubeDescheduler` `cluster`)

| Field | Value |
|-------|--------|
| `mode` | `Automatic` (evicts; use `Predictive` to dry-run) |
| `deschedulingIntervalSeconds` | `3600` |
| Profiles | `SoftTopologyAndDuplicates`, `LifecycleAndUtilization` |

```yaml
# Dry-run only (no evictions)
spec:
  mode: Predictive
```

## Notes

- Descheduler never reschedules system-critical pods owned by static manifests on control plane by default policies; review profile docs before adding `EvictPodsWithPVC` / `EvictPodsWithLocalStorage`.
- VMs with `evictionStrategy: LiveMigrate` cooperate better with deschedule events than hard kill.
