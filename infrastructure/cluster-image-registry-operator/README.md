# cluster-image-registry-operator

Image registry / allowed registries configuration.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-cluster-image-registry-operator` |

```bash
kubectl kustomize infrastructure/cluster-image-registry-operator/overlays/ocp
```

Edit allow-list:

```text
overlays/<cluster>/patch-allowed-registries.yaml
```
