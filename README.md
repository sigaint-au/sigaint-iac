# sigaint-iac

GitOps repository for **Sigaint** OpenShift clusters, managed with **OpenShift GitOps (Argo CD)** and **Kustomize**.

| Cluster | Role | Entry path |
|---------|------|------------|
| `hub` | ACM / management | `clusters/hub/` (infrastructure) |
| `ocp` | Workload / virtualization | `clusters/ocp/` (infrastructure, applications, virtualization) |

Generated Argo CD Applications use prefixes:

| Prefix | Contents |
|--------|----------|
| `hub-*` | Hub infrastructure |
| `infra-*` | OCP infrastructure |
| `app-*` | Workload applications |
| `virt-*` | Virtualization |

Source: `https://github.com/sigaint-au/sigaint-iac`

---

## Repository layout

```text
clusters/
  hub/                    # Hub ApplicationSets + Argo CD bootstrap
    bootstrap/            # Hub AppProjects + hub-root Application
  ocp/                    # OCP ApplicationSets + Argo CD bootstrap
    bootstrap/            # OCP AppProjects + ocp-root Application
infrastructure/           # Operators and platform config
applications/             # Workloads (Quay, Grafana, Victoria*, logging)
virtualization/           # OpenShift Virtualization VMs and multi-network
components/               # Shared Kustomize components (sync waves, SSA)
scripts/                  # Validation helpers
```

Each cluster runs its **own** OpenShift GitOps (Argo CD). Bootstrap manifests under
`clusters/<cluster>/bootstrap/` are applied only on that cluster — never both.

Packages use overlays per cluster:

```text
<name>/
  base/
  overlays/
    hub/                  # when applicable
    ocp/
```

ApplicationSets always target **`…/overlays/<cluster>`**.

---

## Prerequisites

- OpenShift cluster with `oc` logged in as a cluster-admin (or equivalent)
- Network access from the cluster to `https://github.com/sigaint-au/sigaint-iac`
- A Doppler service token for External Secrets (created out-of-band; never committed)

Optional on a workstation:

```bash
# Validate overlays before pushing
command -v kubectl
command -v helm   # required for grafana / victoria-* charts
```

---

## Bootstrap

Clone the repo (or work from a checkout on a machine that can reach the API):

```bash
git clone https://github.com/sigaint-au/sigaint-iac.git
cd sigaint-iac
```

### 1. Install OpenShift GitOps

Install **Red Hat OpenShift GitOps** from the console (*Operators → OperatorHub*), or with a Subscription:

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

# Wait for Argo CD (operator creates openshift-gitops)
oc wait --for=condition=Available deployment/openshift-gitops-server \
  -n openshift-gitops --timeout=300s

# Argo CD UI
oc get route openshift-gitops-server -n openshift-gitops \
  -o jsonpath='https://{.spec.host}{"\n"}'
```

### 2. Day-0 Argo CD permissions (optional)

AppProjects in this repo define allowed sources and destinations. For first-time bootstrap you may temporarily grant the application controller cluster-admin, then remove it after projects and apps are healthy:

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
```

Remove when finished:

```bash
oc delete clusterrolebinding argocd-cluster-admin
```

### 3–4. Bootstrap Argo CD for **this** cluster only

Each cluster has its own Argo CD. Apply **only** the bootstrap directory that
matches the cluster you are logged into:

| Cluster | AppProjects | Root Application | Expected projects |
|---------|-------------|------------------|-------------------|
| `hub` | `clusters/hub/bootstrap/appprojects.yaml` | `clusters/hub/bootstrap/root-application.yaml` | `infrastructure` |
| `ocp` | `clusters/ocp/bootstrap/appprojects.yaml` | `clusters/ocp/bootstrap/root-application.yaml` | `infrastructure`, `applications`, `virtualization` |

**Workload cluster (`ocp`):**

```bash
oc apply -f clusters/ocp/bootstrap/appprojects.yaml
oc apply -f clusters/ocp/bootstrap/root-application.yaml
oc get appprojects,application -n openshift-gitops
```

**Hub cluster (`hub`):**

```bash
oc apply -f clusters/hub/bootstrap/appprojects.yaml
oc apply -f clusters/hub/bootstrap/root-application.yaml
oc get appprojects,application -n openshift-gitops
```

Do **not** apply hub bootstrap on ocp, or ocp bootstrap on hub.

The root Application creates ApplicationSets, which create the prefixed apps
(`hub-*` on hub; `infra-*`, `app-*`, `virt-*` on ocp).

### 5. Bootstrap External Secrets (Doppler)

Do **not** commit a real Doppler token. Create the secret once per cluster **before** or immediately after the External Secrets operator Application syncs:

```bash
oc create namespace external-secrets --dry-run=client -o yaml | oc apply -f -

oc create secret generic doppler-token-auth-api \
  --namespace external-secrets \
  --from-literal=dopplerToken='dp.st.REPLACE_ME' \
  --dry-run=client -o yaml | oc apply -f -
```

Reference example (no live secrets):

`infrastructure/openshift-external-secrets-operator/overlays/<cluster>/doppler-secret.yaml.example`

GitOps owns `ClusterSecretStore` and all `ExternalSecret` objects after this bootstrap secret exists.

### 6. Verify sync

```bash
# Root app
oc get application -n openshift-gitops

# Generated ApplicationSets and apps (prefix depends on cluster)
oc get applicationset -n openshift-gitops
oc get application -n openshift-gitops | grep -E '^(hub|infra|app|virt)-'

# Watch until Healthy/Synced
oc get application -n openshift-gitops -w
```

Argo CD CLI (if installed):

```bash
argocd login "$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')" \
  --grpc-web --sso
argocd app list
```

---

## How sync works

ApplicationSets use:

- Automated sync with `prune` and `selfHeal`
- Server-Side Apply and `RespectIgnoreDifferences`
- Retries with exponential backoff
- Application-level sync waves (operators and storage first, then workloads)
- `targetRevision: main` (pin to a tag or SHA for production freezes)

Shared Kustomize components order OLM installs and instances:

| Component | Purpose |
|-----------|---------|
| `components/operator-sync-wave` | Namespace → OperatorGroup → Subscription |
| `components/operator-instance-sync-wave` | Secrets/CRs after CRDs exist |

| Kind | Wave |
|------|------|
| Namespace | `-10` |
| OperatorGroup / CatalogSource | `-5` |
| Subscription | `-1` |
| Secrets / ExternalSecrets / Certificates | `5` |
| Primary CRs (MetalLB, StorageCluster, Central, …) | `10` |
| Dependent CRs (pools, SecuredCluster, NNCPs, …) | `15+` |

See `components/README.md`.

---

## Post-install checks

### Operators and CSV readiness

```bash
oc get csv -A | grep -v Succeeded || true
oc get subscription -A
```

### Storage nodes (ODF / LSO)

Label nodes as required by your storage design, for example:

```bash
oc label node <node-name> cluster.ocs.openshift.io/openshift-storage=''
```

Local volumes: `infrastructure/local-storage/`  
ODF StorageCluster: `infrastructure/openshift-data-foundation-operator/`

### Image registry allow-list

Edit for each cluster overlay if pulls fail:

```text
infrastructure/cluster-image-registry-operator/overlays/<cluster>/patch-allowed-registries.yaml
```

Include OpenShift release and internal registry hosts.

### MetalLB / networking

OVN and MetalLB settings are GitOps-managed under:

```text
infrastructure/openshift-network-operator/
infrastructure/metallb-operator/
```

### External Secrets

```bash
oc get clustersecretstore
oc get externalsecret -A
oc get secret -n external-secrets doppler-token-auth-api
```

---

## Validate overlays locally

```bash
./scripts/validate-kustomize.sh
```

Requires `kubectl`. Helm-backed apps (`applications/grafana`, `victoria-metrics`, `victoria-logs`) also need `helm` on `PATH` and chart repo access.

CI: `.github/workflows/validate.yaml`.

---

## Add a new package

1. Create `infrastructure|applications|virtualization/<name>/{base,overlays/<cluster>}`.
2. Confirm the overlay builds:

   ```bash
   kubectl kustomize infrastructure/<name>/overlays/ocp
   # Helm packages:
   kubectl kustomize --enable-helm applications/<name>/overlays/ocp
   ```

3. Add an element to the matching ApplicationSet list under `clusters/<cluster>/`.
4. Choose a `wave` relative to dependencies (secrets and cert-manager early; apps later).
5. Run `./scripts/validate-kustomize.sh` and open a PR.

---

## Security practices

| Topic | Practice |
|-------|----------|
| Secrets | External Secrets + Doppler; never commit live tokens |
| Argo CD | Prefer AppProjects; avoid long-lived cluster-admin |
| Images | Pin Helm chart versions; pin tags/digests where practical |
| NetworkPolicy | Prefer default-deny in sensitive namespaces |
| TLS | Prefer service CA / cert-manager |

---

## Optional packages

Present in the tree but **not** wired into ApplicationSets unless you add them:

- `infrastructure/cluster-observability-operator`
- `infrastructure/crunchy-postgres-operator` (Quay uses CloudNativePG)

---

## License

Internal Sigaint platform configuration.
