# tailscale

This module installs the Tailscale client on a cluster and advertises the 
enture service network to the Tailscale network.

## Requirements
* privledged scc to tuntap
* network policy to prevent unwanted traffic

```bash
oc adm policy add-scc-to-user privileged system:serviceaccount:sigaint-tailscale:tailscale
```
