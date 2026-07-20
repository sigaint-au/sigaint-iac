# openshift-logging

Cluster logging stack: LokiStack, log forwarder, console UI plugin.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `app-openshift-logging` |
| Namespace | `openshift-logging` |
| Depends on | `openshift-logging-operator`, `loki-operator`, ODF/NooBaa S3 |

```bash
kubectl kustomize applications/openshift-logging/overlays/ocp
oc get lokistack,clusterlogforwarder -n openshift-logging
```

## S3 (NooBaa OBC example)

OBC can live in `lhm-prod-monitoring`; credentials go to Doppler for External Secrets.

```bash
oc apply -f - <<'EOF'
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: lhm-prod-monitoring-loki
  namespace: lhm-prod-monitoring
spec:
  generateBucketName: lhm-prod-monitoring-loki
  storageClassName: openshift-storage.noobaa.io
EOF

oc get secret -n lhm-prod-monitoring lhm-prod-monitoring-loki -o yaml
```

Wire into External Secrets:

```text
LOKI_S3_ACCESS_KEY_ID
LOKI_S3_ACCESS_KEY_SECRET
LOKI_S3_BUCKETNAMES
LOKI_S3_ENDPOINT
LOKI_S3_REGION
```
