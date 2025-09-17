# Developer Portal Module

This module provisions Konnect Developer Portals with comprehensive configuration options.

## Features

- Complete portal configuration including authentication, approvals, and visibility settings
- Support for RBAC (Role-Based Access Control)
- Integration with Application Auth Strategies
- Comprehensive output values for all portal attributes

## Usage

```hcl
module "developer_portal" {
  source = "./modules/developer_portal"

  name                    = "my-portal"
  description             = "My API developer portal"
  display_name            = "My Developer Portal"

  # Authentication & Access Control
  authentication_enabled  = true
  rbac_enabled           = false

  # Auto-approval settings
  auto_approve_applications = false
  auto_approve_developers = false

  # Default visibility settings
  default_api_visibility  = "private"
  default_page_visibility = "public"

  # Optional auth strategy integration
  default_application_auth_strategy_id = module.auth_strategy.id

  # Lifecycle management
  force_destroy = "false"

  # Labels for organization
  labels = {
    environment = "production"
    team        = "platform"
  }
}
```

## Variables

| Name                                 | Description                                                          | Type          | Default | Required |
| ------------------------------------ | -------------------------------------------------------------------- | ------------- | ------- | :------: |
| name                                 | The name of the Developer Portal                                     | `string`      | n/a     |   yes    |
| description                          | Description for the portal                                           | `string`      | `null`  |    no    |
| display_name                         | The display name of the portal                                       | `string`      | `null`  |    no    |
| labels                               | Labels to attach to the portal                                       | `map(string)` | `{}`    |    no    |
| authentication_enabled               | Whether the portal supports developer authentication                 | `bool`        | `null`  |    no    |
| auto_approve_applications            | Whether application registration requests are automatically approved | `bool`        | `null`  |    no    |
| auto_approve_developers              | Whether developer registrations are automatically approved           | `bool`        | `null`  |    no    |
| default_api_visibility               | Default visibility of APIs ("public" or "private")                   | `string`      | `null`  |    no    |
| default_application_auth_strategy_id | Default authentication strategy ID for APIs                          | `string`      | `null`  |    no    |
| default_page_visibility              | Default visibility of pages ("public" or "private")                  | `string`      | `null`  |    no    |
| rbac_enabled                         | Whether RBAC is enabled for portal resources                         | `bool`        | `null`  |    no    |
| force_destroy                        | Whether to force destroy the portal and all child entities           | `string`      | `null`  |    no    |

## Outputs

| Name                                 | Description                                  |
| ------------------------------------ | -------------------------------------------- |
| id                                   | Portal ID                                    |
| name                                 | Portal name                                  |
| display_name                         | Portal display name                          |
| description                          | Portal description                           |
| canonical_domain                     | The canonical domain of the developer portal |
| default_domain                       | The default Konnect-assigned domain          |
| authentication_enabled               | Whether developer authentication is enabled  |
| auto_approve_applications            | Whether application approvals are automatic  |
| auto_approve_developers              | Whether developer approvals are automatic    |
| default_api_visibility               | Default API visibility setting               |
| default_application_auth_strategy_id | Default auth strategy ID                     |
| default_page_visibility              | Default page visibility setting              |
| rbac_enabled                         | Whether RBAC is enabled                      |
| force_destroy                        | Force destroy setting                        |
| created_at                           | Creation timestamp                           |
| updated_at                           | Last update timestamp                        |
| portal                               | Complete portal resource object              |

## Auth Strategy Integration

When using the `default_application_auth_strategy_name` property in your YAML configuration, the module automatically resolves the strategy name to its ID using the `application_auth_strategy` module reference.

Example YAML configuration:

```yaml
- type: konnect.developer_portal
  name: "my-portal"
  description: "Developer portal for APIs"
  authentication_enabled: true
  auto_approve_applications: false
  auto_approve_developers: false
  default_api_visibility: "private"
  default_application_auth_strategy_name: "my-auth-strategy"
  default_page_visibility: "public"
  rbac_enabled: true
  force_destroy: "false"
  labels:
    environment: "production"
```
