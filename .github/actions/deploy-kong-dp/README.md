# Deploy Kong Data Plane (Composite Action)

Composite GitHub Action to deploy or destroy a Kong data plane into a Kubernetes cluster. Certificates are issued from HashiCorp Vault via `hashicorp/vault-action@v3` and Konnect control-plane endpoints are discovered using the Konnect API.

Stages:

- Setup tooling (kubectl, helm)
- Issue TLS certs from Vault (cluster + proxy)
- Fetch Konnect Control Plane endpoints
- Create Kubernetes secrets and namespace
- Helm install/upgrade of kong-dp and kong-config-exporter
- Destroy path for clean teardown

## Inputs

| Name                   | Required | Default                       | Description                                                                                                                           |
| ---------------------- | -------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| action                 | false    | deploy                        | Action to perform: `deploy` or `destroy`.                                                                                             |
| namespace              | false    | kong                          | Target Kubernetes namespace. For `destroy`, namespace will be deleted.                                                                |
| control-plane-name     | true     | —                             | Konnect Control Plane name used to resolve endpoints via API.                                                                         |
| system-account         | true     | —                             | Konnect system account identifier whose token is stored in Vault at `secret/data/system-accounts/<system-account>` under key `token`. |
| kubeconfig             | true     | —                             | Kubeconfig contents (string). Provide via secret, not a path.                                                                         |
| helm-chart-version     | false    | 2.45.0                        | Kong Helm chart version.                                                                                                              |
| kong-image-repo        | false    | kong/kong-gateway             | Kong image repository.                                                                                                                |
| kong-image-tag         | false    | 3.11.0.2                      | Kong image tag.                                                                                                                       |
| s3-bucket-name         | false    | ""                            | S3 bucket for fallback config consumed by `kong-config-exporter` chart.                                                               |
| s3-prefix              | false    | kong                          | S3 key prefix for fallback config.                                                                                                    |
| deploy-timeout-seconds | false    | 300                           | Timeout for pod readiness and namespace deletion waits.                                                                               |
| values-file            | false    | k8s/values.yaml               | Path to base Helm values file (within the repo workspace).                                                                            |
| vault-address          | true     | —                             | Vault address (e.g., `http://127.0.0.1:8300`).                                                                                        |
| vault-token            | true     | —                             | Vault token with permissions to issue PKI certs and read the system account secret. Provide via secret.                               |
| cert-ttl               | false    | 8760h                         | TTL for issued certificates.                                                                                                          |
| clustering_cn          | false    | kong-cluster                  | Common Name for clustering cert.                                                                                                      |
| proxy_cn               | false    | kong-proxy                    | Common Name for proxy cert.                                                                                                           |
| konnect-api-url        | false    | https://global.api.konghq.com | Base URL for Konnect API.                                                                                                             |
| konnect-api-version    | false    | v2                            | Pinned Konnect API version path segment.                                                                                              |

## Outputs

| Name               | Description                                       |
| ------------------ | ------------------------------------------------- |
| cluster-cert-file  | Path to clustering certificate file (PEM).        |
| cluster-key-file   | Path to clustering key file (PEM).                |
| cluster-ca-file    | Path to clustering CA certificate file (PEM).     |
| proxy-cert-file    | Path to proxy certificate file (PEM).             |
| proxy-key-file     | Path to proxy key file (PEM).                     |
| proxy-ca-file      | Path to proxy CA certificate file (PEM).          |
| cp-endpoint        | Konnect control plane endpoint for DP clustering. |
| telemetry-endpoint | Konnect telemetry endpoint for DP clustering.     |

## Required secrets and variables

- secrets.KUBECONFIG_CONTENTS: Full kubeconfig file contents for the target cluster.
- secrets.VAULT_TOKEN: Token for Vault with read permissions to `pki/issue/kong` and `secret/data/system-accounts/<system-account>` (field `token`).
- vars.VAULT_ADDR: Address of Vault, e.g., `http://127.0.0.1:8300`.

Notes:

- The action uses `hashicorp/vault-action@v3` to request PKI certs at `pki/issue/kong` (role configurable in Vault).
- Issued PEMs are written to temp files and exposed as outputs for downstream steps.
- System account token is retrieved from Vault at `secret/data/system-accounts/<system-account>` with key `token`.
- Control plane and telemetry endpoints are fetched via Konnect API and exported as `KONNECT_CP_ENDPOINT` and `KONNECT_TELEMETRY_ENDPOINT`, and as outputs `cp-endpoint` and `telemetry-endpoint`.
- The runner must have `jq` available for JSON parsing. helm and kubectl are installed by the action.

## Example usage (workflow snippet)

```yaml
name: Deploy Kong DP

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy DP
        uses: ./.github/actions/deploy-kong-dp
        with:
          action: deploy
          namespace: kong
          control-plane-name: my-cp
          system-account: npa_platform
          kubeconfig: ${{ secrets.KUBECONFIG_CONTENTS }}
          values-file: k8s/values.yaml
          helm-chart-version: 2.45.0
          kong-image-repo: kong/kong-gateway
          kong-image-tag: 3.11.0.2
          s3-bucket-name: my-bucket
          s3-prefix: fallback
          deploy-timeout-seconds: 300
          vault-address: ${{ vars.VAULT_ADDR }}
          vault-token: ${{ secrets.VAULT_TOKEN }}
          # Optional overrides
          konnect-api-url: https://global.api.konghq.com
          konnect-api-version: v2
          clustering_cn: kong-cluster
          proxy_cn: kong-proxy
```

To destroy the deployment, set `action: destroy` and keep `namespace` the same.

## Local testing with act and kind/k3d

You can run the workflow locally using `act` against a local cluster (OrbStack, kind, or k3d) and a local dev Vault.

Quick-start (optional helpers in `scripts/`):

1. Bring up dev Vault (and MinIO if desired):

```bash
docker compose up -d vault
```

Then initialize Vault PKI and auth helpers:

```bash
./scripts/setup-vault.sh
```

2. Prepare act config and secrets files:

```bash
./scripts/prep-actrc.sh
./scripts/prep-act-secrets.sh
```

This will create `.actrc` and `act.secrets`. Ensure `VAULT_TOKEN` and `VAULT_ADDR` are set appropriately in your environment or secrets file.

3. Ensure a local Kubernetes cluster is available (OrbStack, kind or k3d) and that your `~/.kube/config` points to it. Export kubeconfig contents for `act` if needed:

```bash
export KUBECONFIG_CONTENTS="$(cat ~/.kube/config)"
```

4. Run the workflow with act (replace the workflow path if using a custom file):

```bash
act -W .github/workflows/deploy-dp.yaml \
  -s KUBECONFIG_CONTENTS="$KUBECONFIG_CONTENTS" \
  -s VAULT_TOKEN="$(grep '^VAULT_TOKEN=' act.secrets | cut -d= -f2-)" \
  -s GITHUB_TOKEN="$(grep '^GITHUB_TOKEN=' act.secrets | cut -d= -f2-)" \
  -v VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8300}
```

If you don't have a workflow yet, copy the example snippet above into `.github/workflows/deploy-dp.yaml`.
