# nvidia-gpu-operator

NVIDIA GPU Operator (certified) with **OpenShift Virtualization PCIe passthrough**
for **Quadro P400 (GP107GL)**.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-nvidia-gpu-operator` |
| Channel | `stable` (`certified-operators`) |
| Namespace | `nvidia-gpu-operator` |
| GPU | Quadro P400 · GP107GL · **PCI `10DE:1CB3`** |
| Audio (same card) | `10DE:0FB9` @ `03:00.1` |
| Depends on | `node-feature-discovery-operator`, `virtualization-operator` |

```bash
kubectl kustomize infrastructure/nvidia-gpu-operator/overlays/ocp
oc get csv -n nvidia-gpu-operator
oc get clusterpolicy gpu-cluster-policy -n nvidia-gpu-operator
```

## Hardware

```text
03:00.0 VGA  NVIDIA GP107GL [Quadro P400]  [10de:1cb3]
03:00.1 Audio NVIDIA GP107GL HD Audio      [10de:0fb9]
```

```bash
oc debug node/<node> -- chroot /host lspci -nnk -d 10de:
```

## ClusterPolicy (passthrough)

| Setting | Value |
|---------|--------|
| `sandboxWorkloads.enabled` | `true` |
| `sandboxWorkloads.defaultWorkload` | `vm-passthrough` |
| `vfioManager` | enabled |
| `sandboxDevicePlugin` | enabled |
| MIG / vGPU manager | disabled (full-device only) |

### Node labels

```bash
oc label node <node> nvidia.com/gpu.workload.config=vm-passthrough --overwrite
```

## HyperConverged

`infrastructure/virtualization-operator/overlays/ocp/hyperconverged.yaml`:

```yaml
pciDeviceSelector: "10DE:1CB3"
resourceName: nvidia.com/GP107GL_QUADRO_P400
externalResourceProvider: true
```

### Attach GPU to a VM

```yaml
spec:
  domain:
    devices:
      gpus:
        - name: p400
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

## Host prep (MachineConfigs)

Workers get (reboot via MCO):

| MachineConfig | Purpose |
|---------------|---------|
| `100-worker-iommu-karg` | `intel_iommu=on` `amd_iommu=on` `iommu=pt` |
| `100-worker-vfio-modules` | Load `vfio` / `vfio_pci`; blacklist `nouveau` |

Without IOMMU, `nvidia-vfio-manager` fails to bind `03:00.0` / `03:00.1` to `vfio-pci`.

```bash
oc get mcp worker
oc debug node/<node> -- chroot /host cat /proc/cmdline | tr ' ' '\n' | grep iommu
oc debug node/<node> -- chroot /host ls /sys/kernel/iommu_groups | wc -l
```

## Prerequisites

- Bare-metal (or nested virt with IOMMU/VT-d exposed)
- NFD labels present
- Allowed registries: `registry.connect.redhat.com`, `nvcr.io`
- Node label: `nvidia.com/gpu.workload.config=vm-passthrough`

## Verify

```bash
oc get pods -n nvidia-gpu-operator
oc logs -n nvidia-gpu-operator -l app=nvidia-vfio-manager --tail=50
oc describe node <node> | grep -A5 'Allocatable\|nvidia.com'
oc get hyperconverged kubevirt-hyperconverged -n openshift-cnv \
  -o jsonpath='{.spec.permittedHostDevices}{"\n"}'
```

### If bind still fails after IOMMU

1. Confirm neither `nvidia` nor `nouveau` holds `03:00.0` / `03:00.1`.
2. Both functions share an IOMMU group — both must be unbound or on `vfio-pci`.
3. BIOS: enable VT-d / AMD-Vi.
