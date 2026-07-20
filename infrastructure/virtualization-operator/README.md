# virtualization-operator

OpenShift Virtualization (CNV) + **HyperConverged** (OCP 4.22-oriented).

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `infra-virtualization-operator` |
| Namespace | `openshift-cnv` |

```bash
kubectl kustomize infrastructure/virtualization-operator/overlays/ocp
oc get hyperconverged kubevirt-hyperconverged -n openshift-cnv
oc get csv -n openshift-cnv
```

## Workload updates

```yaml
spec:
  workloadUpdateStrategy:
    workloadUpdateMethods:
      - LiveMigrate
```

Node pressure / relieve-and-migrate: **KubeDescheduler** profile
`DevKubeVirtRelieveAndMigrate` — `infrastructure/kube-descheduler-operator`.

## Feature gates (enabled)

| Gate | Purpose |
|------|---------|
| `disableMDevConfiguration` | Full PCIe GPU passthrough (P400) |
| `nonRoot` / `autoResourceLimits` | Hardened defaults |
| `downwardMetrics` | VM metrics for monitoring |
| `deployKubeSecondaryDNS` | DNS for Multus / secondary networks |
| `declarativeHotplugVolumes` | Modern volume hotplug |
| `decentralizedLiveMigration` | Current migration control plane |
| `alignCPUs` | Even vCPU alignment for guests |

Also: `deployVmConsoleProxy: true`, `evictionStrategy: LiveMigrateIfPossible`.

### Live migration

| Setting | Value |
|---------|-------|
| `allowAutoConverge` | `true` |
| `allowPostCopy` | `false` |
| `parallelMigrationsPerCluster` | `5` |
| `parallelOutboundMigrationsPerNode` | `2` |

## GPU PCIe passthrough — Quadro P400 (GP107GL)

| Field | Value |
|-------|-------|
| Device | NVIDIA **Quadro P400** (GP107GL) |
| VGA BDF | `03:00.0` |
| PCI ID | **`10DE:1CB3`** |
| Audio | `03:00.1` · `10DE:0FB9` (same IOMMU group) |
| KubeVirt resource | `nvidia.com/GP107GL_QUADRO_P400` |
| Provider | NVIDIA GPU Operator sandbox device plugin (`externalResourceProvider: true`) |

```yaml
# HyperConverged
featureGates:
  disableMDevConfiguration: true
permittedHostDevices:
  pciHostDevices:
    - pciDeviceSelector: "10DE:1CB3"
      resourceName: nvidia.com/GP107GL_QUADRO_P400
      externalResourceProvider: true
```

### Attach to a VM

```yaml
spec:
  domain:
    devices:
      # Required for OpenShift console / VNC when using GPU passthrough.
      autoattachGraphicsDevice: true
      gpus:
        - name: p400
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

**Note:** Keep **`autoattachGraphicsDevice: true`** if you need OpenShift console graphical access while a host GPU is attached.

### Host / operator checklist

```bash
lspci -nnk -d 10de:   # on node
oc get clusterpolicy -n nvidia-gpu-operator
oc label node <node> nvidia.com/gpu.workload.config=vm-passthrough --overwrite
oc get hyperconverged kubevirt-hyperconverged -n openshift-cnv \
  -o jsonpath='{.spec.permittedHostDevices}{"\n"}'
```

Full ClusterPolicy / IOMMU: `infrastructure/nvidia-gpu-operator/README.md`.

## Not in this package

Network flow UI (NetObserv / FlowCollector) is separate platform observability — not configured on HyperConverged.
