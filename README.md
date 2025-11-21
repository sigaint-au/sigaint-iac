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

## metllb-operator

Required for IP Forwarding.
```
oc patch network.operator cluster -p '{"spec":{"defaultNetwork":{"ovnKubernetesConfig":{"gatewayConfig":{"ipForwarding": "Global"}}}}}' --type=merge
```

## cluster-image-registry-operator

Set the allow-listed registries for the cluster.

* https://github.com/sigaint-au/sigaint-iac/tree/main/infrastructure/cluster-image-registry-operator

Ensure you have modified the `overlay/<cluster>/patch-allowed-registries.yaml` file.


## Disk
``` 
oc label nodes lan-node-01 cluster.ocs.openshift.io/openshift-storage=''

```