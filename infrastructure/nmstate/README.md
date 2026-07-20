# nmstate

NMState operator + secondary physnet NNCPs (OVN localnet bridges).

| | |
|--|--|
| Cluster | `ocp` |
| App | `infra-nmstate` |
| Active policy | `physnet1-external-eno2` |

## Labels

```bash
oc label node <node> sigaint.au/physnet=eno2
oc get nodes -l sigaint.au/physnet=eno2
oc get nncp,nnce
```

| Label | Interface |
|-------|-----------|
| `sigaint.au/physnet=eno2` | eno2 (MTU **9000**, `ovs-br1`) |

## Localnets on ovs-br1

```text
mgmt-lhm-prod secure-lhm-prod security-lhm-prod user-lhm-prod
server-lhm-prod dmz-lhm-prod vmnet-lhm-prod
```

Must match NAD CNI names under `virtualization/network-attachment-definitions/`.

```bash
kubectl kustomize infrastructure/nmstate/overlays/ocp
```
