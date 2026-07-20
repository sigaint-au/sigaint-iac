# cluster-image-registry-operator

Image config (`config.openshift.io/v1` `Image` `cluster`) — allowed registries
policy used by kubelet / CRI-O pulls.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-cluster-image-registry-operator` |

```bash
kubectl kustomize infrastructure/cluster-image-registry-operator/overlays/ocp
oc get image.config.openshift.io cluster -o yaml
```

## Allowed registries (ocp)

| Registry | Why |
|----------|-----|
| `quay.sigaint.au` | Internal Quay |
| `quay.io` / `quay.io/openshift-release-dev` | Release / community |
| `image-registry.openshift-image-registry.svc[:5000]` | In-cluster registry |
| `registry.redhat.io` | Red Hat product images |
| `registry.access.redhat.com` | Legacy RH access |
| `registry.connect.redhat.com` | **Certified Operators** (NVIDIA GPU bundle, etc.) |
| `nvcr.io` | NVIDIA NGC driver/runtime images |
| `ghcr.io` / `docker.io` / `registry.k8s.io` | Common third-party |

Edit: `overlays/ocp/patch-allowed-registries.yaml`

## SignatureValidationFailed

If marketplace pods fail with `Source image rejected ... rejected by policy` for
`registry.connect.redhat.com/...`, the host is missing from
`spec.registrySources.allowedRegistries`. Add it and wait for MCO/node policy
refresh (or reboot nodes if policy is sticky).
