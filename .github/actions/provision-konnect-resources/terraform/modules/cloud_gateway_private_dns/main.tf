terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

locals {
  attachment_input = var.private_dns_attachment_config

  # If aws_private_dns_resolver_attachment_config is provided with dns_config as a single object
  # { dns_config = { remote_dns_server_ip_addresses = [...] } }
  # normalize it to the provider-expected map form:
  # { dns_config = { default = { remote_dns_server_ip_addresses = [...] } } }
  resolver_cfg = try(local.attachment_input.aws_private_dns_resolver_attachment_config, null)
  hosted_cfg   = try(local.attachment_input.aws_private_hosted_zone_attachment_config, null)
  dns_cfg_raw  = try(local.resolver_cfg.dns_config, null)
  dns_cfg_from_default = (
    can(local.dns_cfg_raw.remote_dns_server_ip_addresses)
    ? { default = { remote_dns_server_ip_addresses = local.dns_cfg_raw.remote_dns_server_ip_addresses } }
    : {}
  )
  dns_cfg_from_map = (
    can(local.dns_cfg_raw.remote_dns_server_ip_addresses)
    ? {}
    : (local.dns_cfg_raw == null ? {} : tomap(local.dns_cfg_raw))
  )
  dns_cfg_norm = (
    local.resolver_cfg == null || local.dns_cfg_raw == null
    ? null
    : jsondecode(jsonencode(merge({}, local.dns_cfg_from_map, local.dns_cfg_from_default)))
  )

  normalized_attachment = (
    local.attachment_input == null ? null : merge(
      {},
      local.resolver_cfg == null ? {} : {
        aws_private_dns_resolver_attachment_config = {
          kind       = local.resolver_cfg.kind
          dns_config = local.dns_cfg_norm
        }
      },
      local.hosted_cfg == null ? {} : {
        aws_private_hosted_zone_attachment_config = local.hosted_cfg
      }
    )
  )
}

resource "konnect_cloud_gateway_private_dns" "this" {
  network_id = var.network_id
  name       = var.name

  private_dns_attachment_config = local.normalized_attachment
}

output "id" {
  value = konnect_cloud_gateway_private_dns.this.id
}
