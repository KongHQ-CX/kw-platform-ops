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
  config                       = yamldecode(file(var.config_file))
  metadata                     = lookup(local.config, "metadata", {})
  resources                    = lookup(local.config, "resources", [])
  control_planes               = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  api_products                 = [for resource in local.resources : resource if resource.type == "konnect.api_product"]
  apis                         = [for resource in local.resources : resource if resource.type == "konnect.api"]
  api_documents                = [for resource in local.resources : resource if resource.type == "konnect.api_document"]
  api_specifications           = [for resource in local.resources : resource if resource.type == "konnect.api_specification"]
  api_implementations          = [for resource in local.resources : resource if resource.type == "konnect.api_implementation"]
  api_publications             = [for resource in local.resources : resource if resource.type == "konnect.api_publication"]
  cloud_gateway_configurations = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_configuration"]
  cloud_gateway_networks       = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_network"]
  application_auth_strategys   = [for resource in local.resources : resource if resource.type == "konnect.application_auth_strategy"]
  developer_portals            = [for resource in local.resources : resource if resource.type == "konnect.developer_portal"]
  portal_auths                 = [for resource in local.resources : resource if resource.type == "konnect.portal_auth"]
  portal_custom_domains        = [for resource in local.resources : resource if resource.type == "konnect.portal_custom_domain"]
  portal_teams                 = [for resource in local.resources : resource if resource.type == "konnect.portal_team"]
  portal_customizations        = [for resource in local.resources : resource if resource.type == "konnect.portal_customization"]
  portal_pages                 = [for resource in local.resources : resource if resource.type == "konnect.portal_page"]
  portal_snippets              = [for resource in local.resources : resource if resource.type == "konnect.portal_snippet"]
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

  max_retry      = 1
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
}

# module "api_documents" {
#   source = "./modules/api_document"

#   for_each = { for doc in local.api_documents : "${doc.api_name}-${doc.slug}" => doc }

#   api_id             = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   content            = each.value.content
#   labels             = lookup(each.value, "labels", {})
#   parent_document_id = lookup(each.value, "parent_document_id", null)
#   slug               = each.value.slug
#   status             = lookup(each.value, "status", "unpublished")
#   title              = lookup(each.value, "title", null)
# }

# module "api_specifications" {
#   source = "./modules/api_specification"

#   for_each = { for spec in local.api_specifications : "${spec.api_name}-${lookup(spec, "api_version", "")}" => spec }

#   api_id  = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   content = each.value.content
#   type    = lookup(each.value, "spec_type", null)
# }

# module "api_implementations" {
#   source = "./modules/api_implementation"

#   for_each = { for impl in local.api_implementations : "${impl.api_name}-${impl.service.control_plane_name}" => impl }

#   api_id = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   service = {
#     control_plane_id = module.control_planes[each.value.service.control_plane_name].control_plane.id
#     id               = each.value.service.id
#   }
# }

# module "api_publications" {
#   source = "./modules/api_publication"

#   for_each = { for pub in local.api_publications : "${pub.api_name}-${pub.portal_name}" => pub }

#   api_id                     = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   portal_id                  = module.developer_portals[each.value.portal_name].id
#   auth_strategy_ids          = lookup(each.value, "auth_strategy_ids", null) != null ? [for name in each.value.auth_strategy_ids : module.application_auth_strategy[name].id] : null
#   auto_approve_registrations = lookup(each.value, "auto_approve_registrations", null)
#   visibility                 = lookup(each.value, "visibility", "private")
# }

# module "team_role" {
#   source = "./modules/team_role"

#   team = {
#     id   = lookup(local.team, "id", "")
#     name = lookup(local.team, "name", "")
#   }
#   region         = lookup(local.metadata, "region", "")
#   control_planes = [for k, v in module.control_planes : v.control_plane]
#   api_products   = [for k, v in module.api_products : v.api_product]
# }
