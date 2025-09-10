# Konnect Resources composite action

Provision Kong Konnect entities from a YAML manifest using Terraform.

## Inputs

- config (required): Path to YAML manifest
- action: provision|destroy (default: provision)
- plan-only: true to skip apply (default: false)
- konnect-token (required)
- konnect-server-url (default: https://global.api.konghq.com)
- konnect-region (default: eu)
- konnect-team-name (required)
- vault-address (default: http://localhost:8300)
- vault-token (required)
- aws-access-key-id (required)
- aws-secret-access-key (required)
- aws-session-token (optional)
- aws-endpoint-url (optional)
- aws-region (default: eu-central-1)

## Behavior

- Validates YAML shape before running Terraform
- Exposes TF_VARs for Terraform stack
- Initializes Terraform using the local backend defined in `backend.tf`
- Uses `-refresh=false` automatically when konnect-token is `dummy` to allow CI dry-run without network

## Usage

```yaml
jobs:
	plan:
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v4
			- name: Plan
				uses: ./.github/actions/provision-konnect-resources
				with:
					config: docs/examples/konnect/resources.portal-thin-slice.yaml
					action: provision
					plan-only: 'true'
					konnect-token: dummy
					konnect-team-name: flight-operations
					vault-token: dummy
					aws-access-key-id: test
					aws-secret-access-key: test
					aws-endpoint-url: http://minio.local:9000
					aws-region: eu-central-1
```

See `terraform/README.md` for supported YAML resource types and mapping.
