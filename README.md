# sigaint-iac

GitOps repository for **SiGaint** OpenShift clusters, managed with **OpenShift GitOps (Argo CD)** and **Kustomize**.

| Cluster | Role | ApplicationSets |
|---------|------|-----------------|
| `hub` | ACM / management | `clusters/hub/` (infrastructure only) |
| `ocp` | Workload / virtualization | `clusters/ocp/` (infrastructure, applications, virtualization) |

---

## Repository layout

```text
clusters/                 # Argo CD ApplicationSets + bootstrap
  bootstrap/              # AppProjects + root Application manifests
  hub/                    # Hub ApplicationSets
  ocp/                    # OCP ApplicationSets
infrastructure/           # Cluster operators and platform config
applications/             # Product workloads (Quay, Grafana, Victoria*, logging)
virtualization/           # OpenShift Virtualization VMs and multi-network
components/               # Shared Kustomize components (sync-wave, SSA helpers)
scripts/                  # Validation helpers
```

Each package follows:

```text
<name>/
  base/                   # Shared resources
  overlays/
    hub/                  # Hub-specific patches (when applicable)
    ocp/                  # OCP-specific patches
```

Argo CD ApplicationSets always point at **`…/overlays/<cluster>`**.

---

## Bootstrap (new cluster)

### 1. Install OpenShift GitOps

Install the OpenShift GitOps operator and ensure the `openshift-gitops` namespace is ready.

### 2. Scope Argo CD permissions

Prefer **AppProject** allow-lists over cluster-admin. If you must bootstrap with elevated rights:

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
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
```

Tighten this after day-0. AppProjects live in `clusters/bootstrap/appprojects.yaml`.

### 3. Apply AppProjects and root Application

**OCP:**

```bash
oc apply -f clusters/bootstrap/appprojects.yaml
oc apply -f clusters/bootstrap/root-applications.yaml
# Or point a root Application at clusters/ocp after projects exist.
```

**Hub:**

```bash
oc apply -f clusters/bootstrap/appprojects.yaml
oc apply -k clusters/hub
```

Root Application for OCP tracks `clusters/ocp` (ApplicationSets). Generated apps use prefixes:

- `infra-*` — infrastructure
- `app-*` — applications  
- `virt-*` — virtualization  
- `hub-*` — hub infrastructure

### Migrating from pre-refactor app names

Application names are now prefixed (`infra-local-storage`, `app-quay`, …). After deploying this revision, **delete legacy unprefixed Applications** (or let prune remove them if they were owned by an old ApplicationSet) so you do not run two controllers against the same resources.

### 4. Bootstrap External Secrets (Doppler)

**Do not commit the Doppler token.** Create the secret once per cluster:

```bash
oc create namespace external-secrets --dry-run=client -o yaml | oc apply -f -
oc create secret generic doppler-token-auth-api \
  --namespace external-secrets \
  --from-literal=dopplerToken='dp.st....'
```

Example manifest: `infrastructure/openshift-external-secrets-operator/overlays/*/doppler-secret.yaml.example`.

GitOps then owns `ClusterSecretStore` and all `ExternalSecret` objects.

---

## ApplicationSets and sync policy

ApplicationSets use:

- **Automated sync** with `prune` + `selfHeal`
- **Server-Side Apply** + `RespectIgnoreDifferences`
- **Retries** with exponential backoff
- **Sync waves** on Applications (operator/storage first, then workloads)
- **`targetRevision: main`** (pin to a tag/SHA for production freezes)

Within packages, shared Kustomize components enforce OLM-aware ordering:

| Component | Purpose |
|-----------|---------|
| `components/operator-sync-wave` | Namespace → OperatorGroup → Subscription |
| `components/operator-instance-sync-wave` | Secrets/CRs after the operator (CRDs) exists |

**OLM install waves**

| Kind | Wave |
|------|------|
| Namespace | `-10` |
| OperatorGroup / CatalogSource | `-5` |
| Subscription | `-1` |

**Instance waves (selected kinds)**

| Wave | Examples |
|------|----------|
| `0` | Helper RBAC, NetworkPolicy |
| `5` | Secrets, ExternalSecrets, Certificates |
| `10` | Primary CRs (MetalLB, Central, StorageCluster, …) |
| `15+` | Dependent CRs (IP pools, SecuredCluster, NNCPs, …) |

See `components/README.md`.

---

## Day-2 operations notes

### MetalLB / IP forwarding

OVN gateway settings (`routingViaHost`, `ipForwarding: Global`) are managed under:

`infrastructure/openshift-network-operator/`

(No separate imperative `oc patch` required when this Application is healthy.)

### Image registry allow-list

Edit:

`infrastructure/cluster-image-registry-operator/overlays/<cluster>/patch-allowed-registries.yaml`

Include OpenShift release and internal registry hosts or upgrades/pulls will fail.

### Local storage / ODF

Label storage nodes as required by ODF/LSO, for example:

```bash
oc label nodes lan-node-01 cluster.ocs.openshift.io/openshift-storage=''
```

Local volume sets live under `infrastructure/local-storage/`. ODF `StorageCluster` is under `infrastructure/openshift-data-foundation-operator/`.

### ACS (Advanced Cluster Security)

- Central + SecuredCluster are GitOps-managed.
- Init-bundle and OAuth Jobs are Argo CD hooks with `Replace` / `BeforeHookCreation`.
- Default OAuth role is **Analyst** (not Admin). Elevate groups in ACS as needed.
- Collector uses **CORE_BPF**.

### Virtualization

- Prefer `runStrategy: Always` (not deprecated `running: true`).
- SSH keys via ExternalSecrets in `virtualization/access-credentials/`.
- NADs under `virtualization/network-attachment-definitions/` (includes `dhcp-shim`).

---

## Validation

```bash
chmod +x scripts/validate-kustomize.sh
./scripts/validate-kustomize.sh
```

Requires `kubectl` (Kustomize). Helm-backed apps (`grafana`, `victoria-*`) need `helm` on `PATH` and chart repo access when building with `--enable-helm`.

CI workflow: `.github/workflows/validate.yaml`.

---

## Adding a new package

1. Create `infrastructure|applications|virtualization/<name>/{base,overlays/<cluster>}`.
2. Ensure `overlays/<cluster>/kustomization.yaml` builds with `kubectl kustomize`.
3. Add an element to the matching ApplicationSet list in `clusters/<cluster>/`.
4. Set an appropriate `wave` relative to dependencies (secrets/cert-manager early, apps late).
5. Run `./scripts/validate-kustomize.sh`.

---

## Security practices

| Topic | Practice |
|-------|----------|
| Secrets | External Secrets + Doppler; no live tokens in git |
| Argo CD | AppProjects; avoid long-lived cluster-admin |
| Images | Pin Helm chart versions; pin container tags/digests where practical |
| NetworkPolicy | Prefer default-deny in sensitive namespaces (e.g. Tailscale) |
| TLS | Prefer service CA / cert-manager; avoid `insecureSkipVerify` |

---

## Orphan / optional trees

These exist in the tree but are **not** wired into ApplicationSets unless you add them:

- `infrastructure/cluster-observability-operator`
- `infrastructure/crunchy-postgres-operator` (Quay uses CloudNativePG instead)

---

## License / ownership

Internal SiGaint platform configuration. Source: `https://github.com/sigaint-au/sigaint-iac`.
