# openshift-node-tuning

Custom **TuneD** profiles via the platform **Node Tuning Operator**
(`openshift-cluster-node-tuning-operator`). No OLM Subscription — NTO is
cluster-core.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `infra-openshift-node-tuning` |
| Namespace | `openshift-cluster-node-tuning-operator` |

```bash
kubectl kustomize infrastructure/openshift-node-tuning/overlays/ocp
oc get tuned -n openshift-cluster-node-tuning-operator
oc get profile -n openshift-cluster-node-tuning-operator
```

## Profile: `openshift-network-throughput`

| Item | Value |
|------|--------|
| Tuned CR | `openshift-network-throughput` |
| Include base | `openshift-node` |
| Match | `node-role.kubernetes.io/worker` |
| Priority | `20` |

### Tuning focus

| Area | Settings |
|------|----------|
| TCP/socket buffers | `rmem`/`wmem` up to 16 MiB |
| Backlog / somaxconn | Raised for high connection rates |
| Congestion | `bbr` + `fq` (if kernel supports) |
| Neighbor GC | Higher `gc_thresh*` for dense pods |
| RPS | All RX queues `rps_cpus=ffffffff` |
| NIC features | tso/gso/gro/sg where TuneD can set them |
| NIC rings (`eno*`) | RX/TX **4078** (hw max; stock RX was ~453) |

Complements jumbo MTU 9000 on `eno1` / nmstate `eno2` and OVN **8900**.

### Verify on a worker

```bash
oc debug node/<worker> -- chroot /host bash -c '
  tuned-adm active
  sysctl net.core.rmem_max net.core.wmem_max net.ipv4.tcp_congestion_control
  ethtool -g eno1
'
oc get profile -n openshift-cluster-node-tuning-operator \
  -o custom-columns=NAME:.metadata.name,NODE:.spec.config.name,APPLIED:.status.conditions[-1].type
```

Expect `ethtool -g eno1` current RX/TX **4078** after the profile applies.

### Notes

- Masters keep the default OpenShift tuned profiles (not matched).
- To target a subset of workers, add a label match (e.g. `node-role.kubernetes.io/worker` + `sigaint.au/net-throughput=true`) and label nodes.
- `bbr` requires the module; TuneD logs a warning and continues if unavailable.
- Ring sizes match measured `eno1` max (`ethtool -g`). If `eno2` reports a lower max, TuneD may log a non-fatal ethtool error for that NIC — lower `ring` or split devices if needed.
- After raising rings, re-check `ethtool -S eno1 \| grep discard` under load; discards should stop climbing.
