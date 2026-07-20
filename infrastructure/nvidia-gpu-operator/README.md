# nvidia-gpu-operator

Certified **NVIDIA GPU Operator** for OpenShift Virtualization **PCIe passthrough**
of **Quadro P400 (GP107GL)**.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `infra-nvidia-gpu-operator` |
| Channel | `stable` · catalog `certified-operators` |
| Namespace | `nvidia-gpu-operator` |
| Depends on | `node-feature-discovery-operator`, `virtualization-operator` |
| Registries | `registry.connect.redhat.com`, `nvcr.io` (see image config) |

```bash
kubectl kustomize infrastructure/nvidia-gpu-operator/overlays/ocp
oc get csv,sub,clusterpolicy -n nvidia-gpu-operator
```

## Hardware (this cluster)

| BDF | Function | PCI ID | Product |
|-----|----------|--------|---------|
| `03:00.0` | VGA | **`10DE:1CB3`** | NVIDIA GP107GL **Quadro P400** |
| `03:00.1` | Audio | `10DE:0FB9` | GP107GL HD Audio (same IOMMU group) |

```bash
oc debug node/<node> -- chroot /host lspci -nnk -d 10de:
# 03:00.0 ... [Quadro P400] [10de:1cb3]
# 03:00.1 ... Audio ... [10de:0fb9]
```

HyperConverged resource name: **`nvidia.com/GP107GL_QUADRO_P400`**  
(`infrastructure/virtualization-operator/overlays/ocp/hyperconverged.yaml`)

## Layout

```text
base/operator/     Namespace, OperatorGroup, Subscription
base/instance/
  worker-iommu-karg.yaml   # worker kernel args
  master-iommu-karg.yaml   # master kernel args
  cluster-policy.yaml      # ClusterPolicy gpu-cluster-policy
overlays/ocp/
```

## MachineConfigs (IOMMU)

| Name | Role | Kernel arguments |
|------|------|------------------|
| `100-worker-iommu-karg` | worker | `intel_iommu=on` `amd_iommu=on` `iommu=pt` + blacklist `nouveau,snd_hda_intel` |
| `100-master-iommu-karg` | master | same |

```text
rd.driver.blacklist=nouveau,snd_hda_intel
modprobe.blacklist=nouveau,snd_hda_intel
```

MCO **reboots** affected pools when these apply.

```bash
oc get mcp
oc get mc 100-worker-iommu-karg 100-master-iommu-karg
oc debug node/<node> -- chroot /host cat /proc/cmdline | tr ' ' '\n' | grep -E 'iommu|blacklist'
oc debug node/<node> -- chroot /host ls /sys/kernel/iommu_groups | wc -l   # expect > 0
```

Without IOMMU, vfio-manager fails:

```text
unable to detect IOMMU FD .../vfio-dev
failed to bind ... to vfio-pci: invalid argument
```

## ClusterPolicy

`ClusterPolicy` `gpu-cluster-policy` — sandbox / VM passthrough path:

| Field | Value |
|-------|--------|
| `sandboxWorkloads.enabled` | `true` |
| `sandboxWorkloads.defaultWorkload` | `vm-passthrough` |
| `vfioManager` | `true` |
| `sandboxDevicePlugin` | `true` |
| `driver` / `toolkit` / `devicePlugin` / `gfd` | enabled |
| `migManager` / `vgpuManager` | **false** (P400 full-device only) |
| `validator.plugin.WITH_WORKLOAD` | `false` |

### Node label (required on GPU hosts)

```bash
oc label node <node> nvidia.com/gpu.workload.config=vm-passthrough --overwrite
```

## HyperConverged + VM

```yaml
# HCO permittedHostDevices
pciDeviceSelector: "10DE:1CB3"
resourceName: nvidia.com/GP107GL_QUADRO_P400
externalResourceProvider: true   # sandbox-device-plugin
```

```yaml
# VirtualMachine
spec:
  domain:
    devices:
      # Keep true if you still need OpenShift console / VNC graphical console.
      # Setting false can drop the auto-attached virtio GPU used by the console when
      # a host GPU is attached for passthrough.
      autoattachGraphicsDevice: true
      gpus:
        - name: p400
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

**Note:** With host GPU passthrough, set **`autoattachGraphicsDevice: true`** if you still need **OpenShift console** graphical access (VNC). Turning it off can leave the VM without a console display device when only the passthrough GPU is present (guest drivers may not provide console until installed).

## Verify

```bash
# Operator
oc get csv -n nvidia-gpu-operator
oc get pods -n nvidia-gpu-operator
oc logs -n nvidia-gpu-operator -l app=nvidia-vfio-manager --tail=50

# Device on node
oc debug node/<node> -- chroot /host bash -c '
  lspci -nnk -s 03:00
  for d in /sys/bus/pci/devices/0000:03:00.*; do
    echo "=== $d ==="
    printf "id "; cat $d/vendor; echo -n ":"; cat $d/device; echo
    [ -e $d/driver ] && echo "driver: $(basename $(readlink -f $d/driver))" || echo "driver: none"
    [ -e $d/iommu_group ] && echo "iommu_group: $(basename $(readlink -f $d/iommu_group))" || echo "iommu_group: NONE"
  done
'

# Schedulable resource
oc describe node <node> | grep -iE 'nvidia.com|Allocatable' -A3

# HCO
oc get hyperconverged kubevirt-hyperconverged -n openshift-cnv \
  -o jsonpath='{.spec.permittedHostDevices}{"\n"}'
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `SignatureValidationFailed` on `registry.connect.redhat.com` | Allow-list in `cluster-image-registry-operator` |
| `ResolutionFailed` / orphan CSV | `oc get sub,csv,ip -n nvidia-gpu-operator`; delete orphan CSV if unreferenced |
| VFIO bind `invalid argument` | IOMMU on cmdline; groups > 0; reboot after MC |
| Bind fails, driver in use | Free **both** `03:00.0` and `03:00.1` (same group) |
| Wrong device ID in HCO | Live ID is **`1CB3`**, not `1BB4` |

## Related packages

| Package | Role |
|---------|------|
| `node-feature-discovery-operator` | Node hardware labels |
| `virtualization-operator` | HyperConverged + `permittedHostDevices` |
| `cluster-image-registry-operator` | `registry.connect.redhat.com`, `nvcr.io` |
