# advanced-cluster-security-operator

Red Hat Advanced Cluster Security (Central + SecuredCluster).

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `infra-advanced-cluster-security-operator` |
| Depends on | `compliance-operator` (recommended) |

```bash
kubectl kustomize infrastructure/advanced-cluster-security-operator/overlays/ocp
oc get central,securedcluster -A
```

## Bootstrap Jobs

Init-bundle and OAuth jobs use:

```text
registry.redhat.io/openshift4/ose-cli-rhel9:v4.22
```

Do **not** use `image-registry.openshift-image-registry.svc:5000/openshift/cli` — kubelet image
pulls use **node DNS** (e.g. `10.120.14.x`), which cannot resolve in-cluster `.svc` names.
`registry.redhat.io` is on the cluster allowed-registries list.
