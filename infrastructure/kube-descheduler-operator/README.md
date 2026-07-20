# kube-descheduler-operator

Kube Descheduler Operator — rebalances pods and **OpenShift Virtualization**
workloads (relieve-and-migrate).

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
| `mode` | `Automatic` |
| Interval | `3600s` |
| Profiles | `SoftTopologyAndDuplicates`, **`DevKubeVirtRelieveAndMigrate`** |

```yaml
profiles:
  - SoftTopologyAndDuplicates
  - DevKubeVirtRelieveAndMigrate
profileCustomizations:
  devEnableSoftTainter: true
  devDeviationThresholds: AsymmetricLow
  devActualUtilizationProfile: PrometheusCPUCombined
```

`DevKubeVirtRelieveAndMigrate` is Technology Preview. Do **not** combine with
`LifecycleAndUtilization` / `LongLifecycle` / `CompactAndScale`.

## PSI (required)

Worker kernel argument `psi=1` via MachineConfig
`99-openshift-machineconfig-worker-psi-karg` (reboots workers).

```bash
oc get mcp worker
oc get mc 99-openshift-machineconfig-worker-psi-karg
```

## Notes

- HyperConverged uses `workloadUpdateMethods: [LiveMigrate]` for CNV updates;
  node pressure rebalancing is owned here.
- VMs: prefer `evictionStrategy: LiveMigrate` / `LiveMigrateIfPossible`.
