# openshift-service-mesh

OpenShift Service Mesh 3 (Sail Operator) — **Istio ambient** control plane.

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-openshift-service-mesh` |
| Operator | `servicemeshoperator3` · channel `stable` |

```bash
kubectl kustomize infrastructure/openshift-service-mesh/overlays/ocp
oc get csv -A | grep -i mesh
oc get istio,istiocni,ztunnel -A
```

## Resources

| Kind | Name | Notes |
|------|------|--------|
| `Istio` | `default` | `values.profile: ambient` |
| `IstioCNI` | `default` | `values.profile: ambient` |
| `ZTunnel` | `default` | Ambient data plane |

Namespaces: `istio-system`, `istio-cni`, `ztunnel` (label `istio-discovery: enabled`).

## CRD note

Sail `sailoperator.io/v1` does **not** declare top-level `spec.profile`.
Set ambient under **`spec.values.profile`** only (SSA fails if `spec.profile` is present).

```yaml
# correct
spec:
  namespace: istio-system
  values:
    profile: ambient

# wrong — not in schema
spec:
  profile: ambient
```

## Opt-in namespaces

```bash
oc label namespace <app-ns> istio-discovery=enabled
# Ambient (sidecar-less) further uses namespace labels per OSSM 3 docs
```
