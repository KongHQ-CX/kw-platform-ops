terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
    konnect = {
      source = "kong/konnect"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.0.1"
    }
  }
}

locals {
  config                       = yamldecode(file(var.konnect_resources))
  metadata                     = lookup(local.config, "metadata", {})
  resources                    = lookup(local.config, "resources", [])
  control_planes               = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  apis                         = [for resource in local.resources : resource if resource.type == "konnect.api"]
  days_to_hours                = 365 * 24 // 1 year
  expiration_date              = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
  short_names = {
    "Control Planes" = "cp",
    "API Products"   = "ap"
  }
}

data "terracurl_request" "fetch_team" {
  name   = "products"
  url    = "https://global.api.konghq.com/v3/teams?filter[name][eq]=${var.team_name}"
  method = "GET"

  headers = {
    "Authorization" = "Bearer ${var.konnect_access_token}"
  }

  response_codes = [
    200
  ]

  max_retry      = 3
  retry_interval = 10
}

module "control_planes" {
  source = "./modules/control_plane"

  for_each = { for cp in local.control_planes : cp.name => cp }

  name          = each.value.name
  description   = each.value.description
  cloud_gateway = lookup(each.value, "cloud_gateway", false)
  labels        = lookup(each.value, "labels", {})
  cluster_type  = lookup(each.value, "cluster_type", "CLUSTER_TYPE_HYBRID")
  auth_type     = lookup(each.value, "auth_type", "pki_client_certs")

  team = jsondecode(data.terracurl_request.fetch_team.response).data[0]
}

module "apis" {
  source = "./modules/api"

  for_each = { for api in local.apis : "${api.name}-${lookup(api, "version", "")}" => api }

  name         = each.value.name
  deprecated   = lookup(each.value, "deprecated", false)
  description  = lookup(each.value, "description", null)
  labels       = lookup(each.value, "labels", {})
  slug         = lookup(each.value, "slug", null)
  spec_content = file("${var.gh_workspace_path}/${each.value.spec_content.file}")
  api_version  = lookup(each.value, "version", null)
  portals      = lookup(each.value, "portals", [])
}