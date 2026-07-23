# openshift-data-foundation-operator

OpenShift Data Foundation (ODF) operator + StorageCluster.

| Field | Value |
|-------|-------|
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
  managedResources:
    cephCluster:
      cleanupPolicy:
        wipeDevicesFromOtherClusters: true
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

### Wipe disks from a previous Ceph install

`managedResources.cephCluster.cleanupPolicy.wipeDevicesFromOtherClusters: true` is
set on the **StorageCluster** so ocs-operator writes it onto
`CephCluster/ocs-storagecluster-cephcluster`. That allows OSD prepare to wipe
devices that still have metadata from another (or prior) cluster.

This is **not** the destroy confirmation (`cleanupPolicy.confirmation:
yes-really-destroy-data`); it only enables reuse of foreign OSD disks.

```bash
kubectl kustomize infrastructure/openshift-data-foundation-operator/overlays/ocp
oc label node <node> cluster.ocs.openshift.io/openshift-storage=''
oc get storagecluster,cephcluster -n openshift-storage
oc get cephcluster ocs-storagecluster-cephcluster -n openshift-storage \
  -o jsonpath='{.spec.cleanupPolicy.wipeDevicesFromOtherClusters}{"\n"}'
```
