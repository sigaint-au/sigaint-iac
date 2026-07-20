# access-credentials

SSH public-key secrets for KubeVirt VMs (External Secrets → Doppler).

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `virt-access-credentials` |

## Secrets (per namespace)

Namespaces: **`lhm-prod-dmz`**, **`lhm-prod-vmnet`**.

| ExternalSecret | Secret | Doppler key |
|----------------|--------|-------------|
| `ext-sk-lhm-prod-admin` | `ssh-pubkey-lhm-admin` | `SSH_PUBKEY_LHM_ADMIN` |
| `ext-sk-lhm-prod-user` | `ssh-pubkey-lhm-user` | `SSH_PUBKEY_LHM_USER` |

```yaml
# remoteRef (all keys)
conversionStrategy: Default
decodingStrategy: None
metadataPolicy: None
nullBytePolicy: Ignore
```

```bash
kubectl kustomize virtualization/access-credentials/overlays/ocp
oc get externalsecret,secret -n lhm-prod-dmz
oc get externalsecret,secret -n lhm-prod-vmnet
```

### VM accessCredentials

```yaml
accessCredentials:
  - sshPublicKey:
      source:
        secret:
          secretName: ssh-pubkey-lhm-admin
      propagationMethod:
        qemuGuestAgent:
          users: ["admin"]   # guest user
  - sshPublicKey:
      source:
        secret:
          secretName: ssh-pubkey-lhm-user
      propagationMethod:
        qemuGuestAgent:
          users: ["user"]
```
