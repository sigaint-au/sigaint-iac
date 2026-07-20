# openshift-logging

Cluster logging stack: LokiStack, log forwarder, console UI plugin.

| | |
|--|--|
| Cluster | `ocp` |
| App | `app-openshift-logging` |
| Depends on | `openshift-logging-operator`, `loki-operator`, ODF/NooBaa S3 |

```bash
kubectl kustomize applications/openshift-logging/overlays/ocp
```

## S3 (NooBaa OBC)

```bash
# Create OBC (example) then map secret fields into Doppler / ExternalSecret
oc apply -f - <<'EOF'
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: sigaint-monitoring-loki
  namespace: sigaint-monitoring
spec:
  generateBucketName: sigaint-monitoring-loki
  storageClassName: openshift-storage.noobaa.io
EOF

oc get secret -n sigaint-monitoring sigaint-monitoring-loki -o yaml
```

Wire into External Secrets:

```text
LOKI_S3_ACCESS_KEY_ID
LOKI_S3_ACCESS_KEY_SECRET
LOKI_S3_BUCKETNAMES
LOKI_S3_ENDPOINT
LOKI_S3_REGION
```
