terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_gateway_control_plane" "this" {
  name          = var.name
  description   = var.description
  cloud_gateway = var.cloud_gateway
  cluster_type  = var.cluster_type
  auth_type     = var.auth_type
  labels = merge(var.labels, {
    generated_by = "terraform"
  })
}

# DEMO: Create a self-signed certificates for the control plane.
# In a real-world scenario, you would use a proper CA or a managed certificate service
# or provide a vaulted private key to sign the control plane certificate.
# This certificate will be used for clustering control plane - data plane authentication.
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  # Certificate subject information
  subject {
    common_name         = "konnect-${replace(lower(konnect_gateway_control_plane.this.name), " ", "-")}"
    organization        = "Konnect Platform Ops"
    organizational_unit = "Kong Platform Team"
  }

  # Certificate timing
  validity_period_hours = 4380
  early_renewal_hours   = 336

  # Certificate usage permissions
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "encipher_only",
    "server_auth",
    "client_auth"
  ]

  lifecycle {
    create_before_destroy = true
  }
}



resource "time_sleep" "delay" {
  create_duration = "30s"
}

# Upload the public certificate to the control plane
resource "konnect_gateway_data_plane_client_certificate" "this" {
  cert             = tls_self_signed_cert.this.cert_pem
  control_plane_id = konnect_gateway_control_plane.this.id

  depends_on = [time_sleep.delay]
}

# Store the Control Plane Information in Vault
resource "vault_kv_secret_v2" "this" {
  mount               = "${replace(lower(var.team.name), " ", "-")}-kv"
  name                = "control-planes/${konnect_gateway_control_plane.this.name}"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    id                     = konnect_gateway_control_plane.this.id
    name                   = konnect_gateway_control_plane.this.name
    control_plane_endpoint = konnect_gateway_control_plane.this.config.control_plane_endpoint
    telemetry_endpoint     = konnect_gateway_control_plane.this.config.telemetry_endpoint
    clustering_cert        = tls_self_signed_cert.this.cert_pem
    clustering_cert_key    = tls_private_key.this.private_key_pem
  })

  custom_metadata {
    max_versions = 5
  }
}


output "control_plane" {
  value = konnect_gateway_control_plane.this
}
