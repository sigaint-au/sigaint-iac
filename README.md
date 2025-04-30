# Setup

## ArgoCD RBAC

```
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

## Add Node Labels

### Network
```aiignore
# Dell
oc label nodes node-{1..4}.osp.sigaint.au sigaint.au/physnet="eno4"

# Lenovo
oc label nodes node-{5..6}.osp.sigaint.au sigaint.au/physnet="eno2"
```

# Disk
``` 
oc label nodes lan-node-01 cluster.ocs.openshift.io/openshift-storage=''

```