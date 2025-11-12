# Installation

Make sure you have create a new `s3` bucket in nooba and have updated the external secrets.

**objectbucket.yaml**
```
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: sigaint-monitoring-loki
  namespace: sigaint-monitoring
  labels:
    app: noobaa
    bucket-provisioner: openshift-storage.noobaa.io-obc
    noobaa-domain: openshift-storage.noobaa.io
spec:
  additionalConfig:
    bucketclass: noobaa-default-bucket-class
  bucketName: sigaint-monitoring-loki-eb4dcac8-58e2-4847-94ac-a2328aca8c84
  generateBucketName: sigaint-monitoring-loki
  objectBucketName: obc-sigaint-monitoring-sigaint-monitoring-loki
  storageClassName: openshift-storage.noobaa.io
```

## Apply

```
oc apply -f objectbucketclaim.yaml
oc get secret sigaint-monitoring-loki -n sigaint-monitoring  -o yaml
```

Find the following for the external secrets.

* `LOKI_S3_ACCESS_KEY_ID`
* `LOKI_S3_ACCESS_KEY_SECRET`
* `LOKI_S3_BUCKETNAMES`
* `LOKI_S3_ENDPOINT`
* `LOKI_S3_REGION`
