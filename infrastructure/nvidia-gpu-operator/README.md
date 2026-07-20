# nvidia-gpu-operator

NVIDIA GPU Operator (certified) with **OpenShift Virtualization PCIe passthrough**
for **NVIDIA `10DE:1CB3`** (GP107GL / Quadro P400-class; confirm with `lspci -nn`).

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-nvidia-gpu-operator` |
| Channel | `stable` (`certified-operators`) |
| Namespace | `nvidia-gpu-operator` |
| Depends on | `node-feature-discovery-operator`, `virtualization-operator` |

```bash
kubectl kustomize infrastructure/nvidia-gpu-operator/overlays/ocp
oc get csv -n nvidia-gpu-operator
oc get clusterpolicy gpu-cluster-policy -n nvidia-gpu-operator
```

## ClusterPolicy (passthrough)

| Setting | Value |
|---------|--------|
| `sandboxWorkloads.enabled` | `true` |
| `sandboxWorkloads.defaultWorkload` | `vm-passthrough` |
| `vfioManager` | enabled |
| `sandboxDevicePlugin` | enabled |
| MIG / vGPU manager | disabled (P620 full-device only) |

### Node labels

Label workers that host P620 for VM passthrough:

```bash
oc label node <node> nvidia.com/gpu.workload.config=vm-passthrough
# Optional scheduling taint/toleration pair as needed:
# oc taint node <node> nvidia.com/gpu=true:NoSchedule
```

Confirm PCI ID on the node:

```bash
oc debug node/<node> -- chroot /host lspci -nnk -d 10de:
# This cluster: 03:00.0 [10de:1cb3], audio 03:00.1 [10de:0fb9]
```

## HyperConverged

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
        - name: gpu1
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

## Host prep (MachineConfigs)

Workers get (reboot via MCO):

| MachineConfig | Purpose |
|---------------|---------|
| `100-worker-iommu-karg` | `intel_iommu=on` `amd_iommu=on` `iommu=pt` |
| `100-worker-vfio-modules` | Load `vfio` / `vfio_pci`; blacklist `nouveau` |

Without IOMMU, `nvidia-vfio-manager` logs:

```text
unable to detect IOMMU FD .../vfio-dev: no such file or directory
failed to bind ... to vfio-pci: invalid argument
```

```bash
oc get mcp worker
# After reboot:
oc debug node/<node> -- chroot /host cat /proc/cmdline | tr ' ' '\n' | grep iommu
oc debug node/<node> -- chroot /host ls /sys/kernel/iommu_groups | head
oc debug node/<node> -- chroot /host find /sys/bus/pci/devices -name vfio-dev 2>/dev/null | head
```

## Prerequisites

- Bare-metal (or nested virt with IOMMU/VT-d exposed); IOMMU MachineConfig above
- NFD labels present (`feature.node.kubernetes.io/*`)
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

1. Confirm P620 is not held by `nvidia`/`nouveau` host driver on passthrough nodes.
2. Check IOMMU group: GPU + audio (`03:00.0` / `03:00.1`) often share a group — both must be unbound.
3. BIOS: enable VT-d / AMD-Vi and disable ACS quirks only if RH/vendor docs require it.
