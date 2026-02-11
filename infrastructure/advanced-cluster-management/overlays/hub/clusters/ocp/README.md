# Usage

## Control Plane

Nodes 1,5,6 get control-plane.
```
oc label agent -n infra-hosting 0dbc1245-f105-4561-9bfd-8e65634c1051 node-role.kubernetes.io/control-plane=""
oc label agent -n infra-hosting 0453e16a-d361-b700-abd7-5be96f9d4d81 node-role.kubernetes.io/control-plane=""
oc label agent -n infra-hosting 81f81244-ec6c-9cde-64b0-09cc8959e07e  node-role.kubernetes.io/control-plane=""

```

## Workers

All nodes should get worker role.
```
oc label agent -n infra-hosting --all node-role.kubernetes.io/worker=""
```