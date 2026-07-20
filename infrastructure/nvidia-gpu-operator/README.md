# nvidia-gpu-operator

NVIDIA GPU Operator (certified) with **OpenShift Virtualization PCIe passthrough**
support for **Quadro P620** (`10DE:1BB4`).

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
# Expect: Quadro P620 [10de:1bb4]
```

## HyperConverged (P620)

`infrastructure/virtualization-operator/overlays/ocp/hyperconverged.yaml` permits:

```yaml
pciDeviceSelector: "10DE:1BB4"
resourceName: nvidia.com/GP107GL_QUADRO_P620
externalResourceProvider: true
```

### Attach GPU to a VM

```yaml
spec:
  domain:
    devices:
      gpus:
        - name: gpu1
          deviceName: nvidia.com/GP107GL_QUADRO_P620
```

## Prerequisites

- IOMMU enabled on the host (virt / bare-metal install)
- NFD labels present (`feature.node.kubernetes.io/*`)
- Allowed registries include **`registry.connect.redhat.com`** (operator bundle)
  and **`nvcr.io`** (drivers) — see `cluster-image-registry-operator`

## Verify

```bash
oc get pods -n nvidia-gpu-operator
oc describe node <node> | grep -A5 'Allocatable\|nvidia.com'
oc get hyperconverged kubevirt-hyperconverged -n openshift-cnv \
  -o jsonpath='{.spec.permittedHostDevices}{"\n"}'
```
