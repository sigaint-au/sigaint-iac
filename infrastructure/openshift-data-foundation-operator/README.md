# openshift-data-foundation-operator

OpenShift Data Foundation (ODF) operator + StorageCluster.

| | |
|--|--|
| Clusters | `ocp` (primary), `hub` overlay present |
| App | `infra-openshift-data-foundation-operator` |
| Backing | LSO `local-block`, flexible scaling |

## OCP StorageCluster

```yaml
# overlays/ocp/storagecluster.yaml (summary)
spec:
  flexibleScaling: true
  monDataDirHostPath: /var/lib/rook
  resourceProfile: lean
  storageDeviceSets:
    - name: ocs-deviceset-local-block
      count: 15
      replica: 1
      portable: false
      dataPVCTemplate:
        spec:
          storageClassName: local-block
          volumeMode: Block
```

```bash
kubectl kustomize infrastructure/openshift-data-foundation-operator/overlays/ocp
oc label node <node> cluster.ocs.openshift.io/openshift-storage=''
oc get storagecluster,cephcluster -n openshift-storage
```
