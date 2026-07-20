# virtualization-operator

OpenShift Virtualization (CNV) + HyperConverged.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-virtualization-operator` |

```bash
kubectl kustomize infrastructure/virtualization-operator/overlays/ocp
oc get hyperconverged -n openshift-cnv
```

## Workload updates

```yaml
spec:
  workloadUpdateStrategy:
    workloadUpdateMethods:
      - LiveMigrate
```

Node relieve-and-migrate for virt is configured on **KubeDescheduler**
(`DevKubeVirtRelieveAndMigrate`) — see `infrastructure/kube-descheduler-operator`.

## GPU PCIe passthrough — Quadro P400 (GP107GL)

| | |
|--|--|
| PCI | **`10DE:1CB3`** @ `03:00.0` |
| Audio | `10DE:0FB9` @ `03:00.1` (same IOMMU group) |
| Resource | `nvidia.com/GP107GL_QUADRO_P400` |
| Provider | NVIDIA GPU Operator sandbox device plugin |

```yaml
# HyperConverged (configured in overlays/ocp/hyperconverged.yaml)
permittedHostDevices:
  pciHostDevices:
    - pciDeviceSelector: "10DE:1CB3"
      resourceName: nvidia.com/GP107GL_QUADRO_P400
      externalResourceProvider: true
```

```yaml
# VM attach
spec:
  domain:
    devices:
      gpus:
        - name: p400
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

See `infrastructure/nvidia-gpu-operator/README.md` for ClusterPolicy, IOMMU, and node labels.
