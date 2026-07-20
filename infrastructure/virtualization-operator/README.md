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

## GPU PCIe passthrough (NVIDIA)

HyperConverged permits host device **`10DE:1CB3`** (GP107GL / Quadro P400-class) as
`nvidia.com/GP107GL_QUADRO_P400` (`externalResourceProvider: true` via GPU Operator).

```yaml
# VM attach
spec:
  domain:
    devices:
      gpus:
        - name: gpu1
          deviceName: nvidia.com/GP107GL_QUADRO_P400
```

See `infrastructure/nvidia-gpu-operator/README.md`.
