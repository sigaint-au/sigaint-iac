# virtualization-operator

OpenShift Virtualization (CNV) + **HyperConverged**.

| | |
|--|--|
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

## GPU PCIe passthrough — Quadro P400 (GP107GL)

| | |
|--|--|
| Device | NVIDIA **Quadro P400** (GP107GL) |
| VGA BDF | `03:00.0` |
| PCI ID | **`10DE:1CB3`** |
| Audio | `03:00.1` · `10DE:0FB9` (same IOMMU group) |
| KubeVirt resource | `nvidia.com/GP107GL_QUADRO_P400` |
| Provider | NVIDIA GPU Operator sandbox device plugin (`externalResourceProvider: true`) |

Configured in `overlays/ocp/hyperconverged.yaml`:

```yaml
featureGates:
  disableMDevConfiguration: true   # full PCIe passthrough (not mdev/vGPU)
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
      gpus:
        - name: p400
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

### Host / operator checklist

```bash
# PCI (on node)
lspci -nnk -d 10de:

# GPU Operator
oc get clusterpolicy -n nvidia-gpu-operator
oc label node <node> nvidia.com/gpu.workload.config=vm-passthrough --overwrite

# HCO
oc get hyperconverged kubevirt-hyperconverged -n openshift-cnv \
  -o jsonpath='{.spec.permittedHostDevices}{"\n"}'
```

Full ClusterPolicy, IOMMU MachineConfigs, and vfio troubleshooting:
**`infrastructure/nvidia-gpu-operator/README.md`**.
