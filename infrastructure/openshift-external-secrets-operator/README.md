# openshift-external-secrets-operator

External Secrets Operator + Doppler `ClusterSecretStore`.

| Field | Value |
|-------|-------|
| Clusters | `hub`, `ocp` |

## Bootstrap secret (once per cluster)

```bash
oc create namespace external-secrets --dry-run=client -o yaml | oc apply -f -
oc create secret generic doppler-token-auth-api   -n external-secrets   --from-literal=dopplerToken='dp.st.REPLACE_ME'   --dry-run=client -o yaml | oc apply -f -
```

```text
overlays/*/doppler-secret.yaml.example
```

```bash
kubectl kustomize infrastructure/openshift-external-secrets-operator/overlays/ocp
oc get clustersecretstore
oc get externalsecret -A
```
