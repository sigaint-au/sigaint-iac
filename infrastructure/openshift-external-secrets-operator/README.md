# External Secrets Operator

## Installation
Dependiing on which cluster youre deploying to. E.g `dmz` or `vmnet` you will
use a different secret store provider.

### Dmz Cluster

* Apply the `overlays/dmz/doppler-secret.yaml` file with the correct token.
* Apply the `SecretStore`