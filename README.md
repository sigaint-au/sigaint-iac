# sigaint-iac

[![validate](https://github.com/sigaint-au/sigaint-iac/actions/workflows/validate.yaml/badge.svg)](https://github.com/sigaint-au/sigaint-iac/actions/workflows/validate.yaml)

GitOps for Sigaint OpenShift clusters — **OpenShift GitOps (Argo CD)** + **Kustomize**.

| Cluster | Role | Entry |
|---------|------|--------|
| `hub` | ACM / management | `clusters/hub/` |
| `ocp` | Workloads / virtualization | `clusters/ocp/` |

| App prefix | Scope |
|------------|--------|
| `hub-*` | Hub infrastructure |
| `infra-*` | OCP infrastructure |
| `app-*` | Workloads |
| `virt-*` | Virtualization |

Repo: `https://github.com/sigaint-au/sigaint-iac`

## Layout

```text
clusters/<cluster>/          # ApplicationSets + bootstrap (per-cluster Argo CD)
  bootstrap/                 # AppProjects + root Application (apply only on that cluster)
infrastructure/              # Operators & platform config
applications/                # Workloads (Quay, OpenShift Logging)
virtualization/              # KubeVirt / Multus / credentials
components/                  # Shared Kustomize components
scripts/validate-kustomize.sh
```

```text
<package>/
  base/
  overlays/<cluster>/        # ApplicationSets target this path
```

Each cluster runs **its own** Argo CD. Never apply hub bootstrap on ocp (or vice versa).

## Validate

```bash
./scripts/validate-kustomize.sh
# requires: kubectl (helm if a package uses helmCharts)
```

## Bootstrap

```bash
git clone https://github.com/sigaint-au/sigaint-iac.git && cd sigaint-iac
```

### 1. OpenShift GitOps

```bash
oc apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

oc wait --for=condition=Available deployment/openshift-gitops-server \
  -n openshift-gitops --timeout=300s

oc get route openshift-gitops-server -n openshift-gitops \
  -o jsonpath='https://{.spec.host}{"\n"}'
```

### 2. Optional day-0 RBAC

```bash
oc apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-cluster-admin
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

# after projects/apps healthy:
oc delete clusterrolebinding argocd-cluster-admin
```

### 3. Root app (this cluster only)

**ocp**

```bash
oc apply -f clusters/ocp/bootstrap/appprojects.yaml
oc apply -f clusters/ocp/bootstrap/root-application.yaml
oc get appprojects,application -n openshift-gitops
```

**hub**

```bash
oc apply -f clusters/hub/bootstrap/appprojects.yaml
oc apply -f clusters/hub/bootstrap/root-application.yaml
oc get appprojects,application -n openshift-gitops
```

| Cluster | Projects |
|---------|----------|
| `hub` | `infrastructure` |
| `ocp` | `infrastructure`, `applications`, `virtualization` |

### 4. External Secrets (Doppler)

```bash
oc create namespace external-secrets --dry-run=client -o yaml | oc apply -f -

oc create secret generic doppler-token-auth-api \
  --namespace external-secrets \
  --from-literal=dopplerToken='dp.st.REPLACE_ME' \
  --dry-run=client -o yaml | oc apply -f -
```

Example: `infrastructure/openshift-external-secrets-operator/overlays/<cluster>/doppler-secret.yaml.example`

### 5. Verify

```bash
oc get application,applicationset -n openshift-gitops
oc get application -n openshift-gitops | grep -E '^(hub|infra|app|virt)-'
```

## Sync model

| Setting | Value |
|---------|--------|
| Policy | automated prune + selfHeal |
| Apply | Server-Side Apply |
| Revision | `main` (pin for freezes) |
| Waves | see [`components/`](components/README.md) |

```text
-10 Namespace
 -5 OperatorGroup / CatalogSource
 -1 Subscription
  5 Secrets / Certificates / ExternalSecretsConfig
 10 Primary CRs (ClusterSecretStore, StorageCluster, MetalLB, …)
15+ Dependents (ExternalSecret, pools, NNCPs, …)
```

## Operator channels

OLM Subscription channels pinned in this repo (package path under `infrastructure/`):

| Operator package | Channel | Clusters |
|------------------|---------|----------|
| `advanced-cluster-management` | `release-2.15` | hub |
| `advanced-cluster-security-operator` | `stable` | ocp |
| `cloudnative-pg-operator` | `stable-v1` | ocp |
| `cluster-observability-operator` | `stable` | optional |
| `compliance-operator` | `stable` | ocp |
| `container-security-operator` | `stable-3.16` | ocp |
| `crunchy-postgres-operator` | `v5` | optional |
| `grafana-operator` | `v5` | ocp |
| `kiali-operator` | `stable` | ocp |
| `local-storage` | `stable` | hub, ocp |
| `loki-operator` | `stable-6.6` | ocp |
| `lvm-storage` | `stable-4.22` | hub |
| `metallb-operator` | `stable` | ocp |
| `nmstate` | `stable` | ocp |
| `openshift-cert-manager-operator` | `stable-v1` | hub, ocp |
| `openshift-data-foundation-operator` | `stable-4.22` | hub, ocp |
| `openshift-external-secrets-operator` | `stable-v1` | hub, ocp |
| `openshift-logging-operator` | `stable-6.6` | hub, ocp |
| `openshift-pipelines-operator` | `latest` | ocp |
| `openshift-service-mesh` | `stable` | ocp |
| `quay-operator` | `stable-3.16` | ocp |
| `virtualization-operator` | `stable` | ocp |

Platform config packages (no OLM channel): `openshift-apiserver-operator`, `openshift-console-operator`, `openshift-ingress-operator`, `openshift-machine-config-operator`, `openshift-network-operator`, `cluster-image-registry-operator`.

Logging and Loki stay on the **same minor** (`stable-6.6`).

## Ops checks

```bash
oc get csv -A | grep -v Succeeded || true
oc get clustersecretstore
oc get externalsecret -A
oc get network.config.openshift.io cluster \
  -o jsonpath='{.status.clusterNetworkMTU}{"\n"}'
```

```bash
# ODF storage nodes
oc label node <node> cluster.ocs.openshift.io/openshift-storage=''

# Secondary physnet (eno2 jumbo)
oc label node <node> sigaint.au/physnet=eno2
```

## Add a package

```bash
# 1. scaffold base + overlays/<cluster>
# 2. build
kubectl kustomize infrastructure/<name>/overlays/ocp
kubectl kustomize --enable-helm applications/<name>/overlays/ocp

# 3. register in clusters/<cluster>/* ApplicationSet (wave)
# 4. validate
./scripts/validate-kustomize.sh
```

## Security

| Topic | Practice |
|-------|----------|
| Secrets | External Secrets + Doppler — never commit tokens |
| Argo CD | AppProjects; no long-lived cluster-admin |
| Images | Pin chart / image versions |
| Network | Prefer default-deny NetworkPolicies |

## Optional (not in ApplicationSets)

- `infrastructure/cluster-observability-operator`
- `infrastructure/crunchy-postgres-operator`

## License

Internal Sigaint platform configuration.
