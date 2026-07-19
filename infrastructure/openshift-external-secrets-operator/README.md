# OpenShift External Secrets Operator

Installs the External Secrets Operator, instance config, and a Doppler `ClusterSecretStore`.

## Bootstrap secret

Create the Doppler API token **once** per cluster (never commit it):

```bash
oc create secret generic doppler-token-auth-api \
  -n external-secrets \
  --from-literal=dopplerToken='dp.st....'
```

See `overlays/*/doppler-secret.yaml.example`.
