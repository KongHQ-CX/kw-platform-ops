
# Kong Platform Ops — Platform Engineering GitHub Actions

This repository contains the Platform Engineering tooling and documentation used by the Kong Professional Services team that operates the Kong-managed API platform for the fictional airline "Kong Air".

The platform team provides a set of GitHub Actions and workflows as a service to API teams. The API teams consume those actions from their own repositories (for example, to publish API configuration or other resources), while platform operators run the platform-level workflows to provision and manage shared infrastructure.

This README documents:

- The platform-run workflows: `deploy-dp.yaml`, `developer-portal.yaml`, and `onboard-konnect-teams.yaml`.
- The team-facing actions (services) provided to API teams: `provision-konnect-resources` and `publish-api-configuration`.
- How the repository uses Terraform with the Konnect provider to manage Konnect resources.

## Who runs what

- Platform team operators: run the workflows located under `.github/workflows/` that manage shared platform resources (developer portals, Kong dataplanes, onboarding konnect teams).
- API teams: call the reusable actions (under `.github/actions/`) from their repositories to request platform-managed work (for example,  publishing API configuration).

## Platform-run workflows

These workflows are intended to be executed by platform engineers (they appear in `.github/workflows/`) and are usually run either manually (workflow_dispatch) or triggered by changes to configuration files in this repo.

1) `deploy-dp.yaml`

- Purpose: Deploy or update a Kong Data Plane (DP) instance into a Kubernetes cluster using a Helm chart.
- Triggers: manual (`workflow_dispatch`) and push changes to specific paths.
- High level steps:
	- Checkout the repository
	- Call the custom action `./.github/actions/deploy-kong-dp` which encapsulates the deployment logic (Helm chart install/upgrade, image tag control, and optional cluster-specific overrides)
	- Inputs include the target namespace, control plane name, system account name, Kubeconfig secret, Helm chart version, Kong image tag, S3 bucket for app state, Vault configuration for secrets, and optional Konnect API connection overrides.

This workflow is used by the platform team to manage the runtime instances of Kong Gateway dataplanes deployed into customer clusters.

2) `developer-portal.yaml`

- Purpose: Provision or destroy a Konnect Developer Portal environment (a set of Konnect and cloud resources) for API teams.
- Triggers: manual (`workflow_dispatch`) and push changes to `portal/*.yaml`.
- High level steps:
	- Checkout the repository
	- Ensure Terraform state storage (S3 bucket) exists
	- Call the reusable action `./.github/actions/provision-konnect-resources` with inputs such as `konnect-resources` config, Vault credentials, AWS credentials, and konnect server URL and token.

The action `provision-konnect-resources` applies a Terraform configuration (contained in `terraform/konnect-...` or another directory) that uses the Konnect Terraform provider to create and manage resources like developer portals, teams, roles, or other Konnect objects. The platform team runs this workflow to provision shared portals that API teams can use.

3) `onboard-konnect-teams.yaml`

- Purpose: Bulk onboard Konnect teams defined in `teams/*.yaml` by applying a Terraform configuration that defines Konnect team resources.
- Triggers: manual (`workflow_dispatch`) and push changes to `teams/*.yaml`.
- High level steps:
	- Checkout repository
	- Validate all YAML team files using `yq` (syntax checks, ensure required fields such as `name`, validate `entitlements` etc.)
	- Ensure Terraform state S3 bucket exists
	- Run `terraform init` and `terraform plan` and `terraform apply` against the Terraform directory `terraform/konnect-teams` using the environment variables and secrets provided by the GitHub Actions environment (e.g., `KONNECT_SERVER_URL`, `KONNECT_TOKEN`, `VAULT_*`, and AWS credentials).

The Terraform configuration consumed here uses the Konnect Terraform provider to create/update Konnect teams and related configuration. This workflow is owned and executed by the platform team to synchronize the `teams/` YAML source-of-truth into Konnect.

## Actions provided to API teams

Two primary actions in this repository are designed to be consumed by API teams (these live under `.github/actions/`). Platform engineers implement, maintain and run these actions for consistency and security.

- `provision-konnect-resources` (used by `developer-portal.yaml`):
	- Purpose: Encapsulate the Terraform provisioning pipeline for Konnect resources. It takes a resources config (YAML), Vault and AWS credentials, Konnect server URL and token, and orchestrates `terraform init/plan/apply` in the proper Terraform directory.
	- Typical usage: API teams may request the platform team to run this action, or the platform team exposes it as a reusable action for controlled self-service.
	- Internally: it uses the Konnect Terraform provider along with other providers (AWS S3 backend, HashiCorp Vault provider for secrets) to provision Konnect entities like developer portals, roles, and team-level settings.

- `publish-api-configuration` (service provided to API teams):
	- Purpose: Publish or update API configuration (routes, services, plugins) into Konnect using automation maintained by the platform team.
	- Typical usage: Invoked by API teams from their CI when they want to publish an API spec or update gateway configuration. The action prepares the appropriate Terraform plan or API calls (via the Konnect provider or Konnect APIs) and ensures the configuration is applied consistently.

Note: Look under `.github/actions/` for the concrete action implementations and expected inputs/outputs. These actions provide a stable interface so API teams don't need to manage Terraform or Konnect credentials themselves.

## How Konnect Terraform providers are used

This repository leverages Terraform configurations that reference the Konnect provider to manage Konnect resources declaratively. Typical patterns:

- A Terraform module or set of Terraform files declares Konnect resources (teams, developer portals, API publication objects). The Konnect provider authenticates to Konnect using `KONNECT_SERVER_URL` and `KONNECT_TOKEN` (provided via GitHub Actions secrets/vars).
- Terraform state is stored in an S3 backend (`AWS_S3_BUCKET`) to enable reproducible runs and to be used by multiple GitHub Actions runs.
- The platform workflows run `terraform init`, `terraform plan`, and `terraform apply` inside the appropriate working directory (for example, `terraform/konnect-teams`), using the configured backend and providers.
- The `provision-konnect-resources` action wraps this behavior to ensure consistent, repeatable provisioning with proper secret handling (via Vault) and input validation.

## Repo layout (high level)

- `.github/workflows/` — Workflow definitions you run as platform operators (see files above).
- `.github/actions/` — Reusable custom actions the platform exposes to API teams (e.g., `provision-konnect-resources`, `deploy-kong-dp`, `publish-api-configuration`).
- `terraform/konnect-teams/` — Terraform code used to provision Konnect teams and their related resources.
- `teams/` — YAML source-of-truth defining the Konnect teams to onboard.
- `konnect/` — Developer portal and other Konnect-specific resource declarations used for provisioning.

## Running the workflows (operator notes)

- Before running any workflow, ensure that required GitHub repository secrets and organization variables are set:
	- `KONNECT_TOKEN` (secret) and `KONNECT_SERVER_URL` (var)
	- `VAULT_TOKEN` and `VAULT_ADDR` (if Vault integration is used to store secrets)
	- AWS credentials for S3 backend (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) and `AWS_REGION`
	- `KUBECONFIG_CONTENTS` for `deploy-dp` that needs to access the cluster

- These workflows are typically executed by a platform operator account that has access to the Konnect control plane and to secrets in Vault and AWS.

## Security and best-practices

- Keep `KONNECT_TOKEN` limited in scope and rotate periodically.
- Use Hashicorp Vault to store sensitive credentials and provide short-lived tokens to workflows where possible.
- Use S3 backend with proper encryption and access controls for Terraform state.
- Validate input YAML files (as the `onboard-konnect-teams` workflow does) before applying infrastructure changes.

## Where to look for implementations

- Workflows: `.github/workflows/deploy-dp.yaml`, `.github/workflows/developer-portal.yaml`, `.github/workflows/onboard-konnect-teams.yaml` (see this repo).
- Actions: `.github/actions/provision-konnect-resources`, `.github/actions/deploy-kong-dp`, `.github/actions/publish-api-configuration` (inspect each action's `action.yml` or `Dockerfile` / `entrypoint.sh` for concrete behavior).
- Terraform: `terraform/konnect-teams/`, `terraform/...` (other directories) — the provider configuration and modules used to manage Konnect resources.

