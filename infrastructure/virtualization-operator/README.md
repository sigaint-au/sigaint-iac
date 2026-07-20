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

## GPU PCIe passthrough (NVIDIA P620)

HyperConverged permits host device **`10DE:1BB4`** as `nvidia.com/GP107GL_QUADRO_P620`
(`externalResourceProvider: true` via NVIDIA GPU Operator sandbox plugin).

See `infrastructure/nvidia-gpu-operator/README.md` for ClusterPolicy, node labels, and VM attach example.
