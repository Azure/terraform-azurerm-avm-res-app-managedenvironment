variable "certificates" {
  type = map(object({
    # Direct certificate upload
    certificate_password = optional(string)
    certificate_value    = optional(string)

    # Key Vault reference
    key_vault_url      = optional(string)
    key_vault_identity = optional(string) # or "System"

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of certificates to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

Each certificate can be configured in one of two ways:

**Direct Certificate Upload:**
- `certificate_password` - (Optional) The password for the certificate (WriteOnly). Required when using direct certificate upload.
- `certificate_value` - (Optional) The PFX or PEM blob for the certificate (WriteOnly). Required when using direct certificate upload.

**Key Vault Reference:**
- `key_vault_url` - (Optional) URL pointing to the Azure Key Vault secret that holds the certificate. Required when using Key Vault reference.
- `key_vault_identity` - (Optional) Resource ID of a managed identity to authenticate with Azure Key Vault, or 'System' to use a system-assigned identity. Required when using Key Vault reference.

---
`timeouts` block supports the following:
- `create` - (Defaults to 30 minutes) Used when creating the certificate.
- `delete` - (Defaults to 30 minutes) Used when deleting the certificate.
- `read` - (Defaults to 5 minutes) Used when retrieving the certificate.
- `update` - (Defaults to 30 minutes) Used when updating the certificate.

Examples:

Direct certificate upload:
```
certificates = {
  "my-cert" = {
    certificate_password = "password123"
    certificate_value    = file("./cert.pfx")
  }
}
```

Key Vault reference with system-assigned identity:
```
certificates = {
  "my-kv-cert" = {
    key_vault_url      = "https://myvault.vault.azure.net/secrets/mycert"
    key_vault_identity = "System"
  }
}
```

Key Vault reference with user-assigned identity:
```
certificates = {
  "my-kv-cert" = {
    key_vault_url      = "https://myvault.vault.azure.net/secrets/mycert"
    key_vault_identity = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myidentity"
  }
}
```
DESCRIPTION
  nullable    = false
}

variable "custom_domain_certificate_key_vault_identity" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Resource ID of a managed identity to authenticate with Azure Key Vault for the custom domain certificate, or 'System' to use a system-assigned identity.

This is used when configuring a custom domain for the entire environment (not individual certificates).

Must be used in conjunction with `custom_domain_certificate_key_vault_url`.
DESCRIPTION
}

variable "custom_domain_certificate_key_vault_url" {
  type        = string
  default     = null
  description = <<DESCRIPTION
URL pointing to the Azure Key Vault secret that holds the certificate for the custom domain.

This is used when configuring a custom domain for the entire environment (not individual certificates).

Must be used in conjunction with `custom_domain_certificate_key_vault_identity`.
DESCRIPTION
}

variable "custom_domain_certificate_value" {
  type        = string
  default     = null
  description = <<DESCRIPTION
PFX or PEM blob for the custom domain certificate (WriteOnly).

This is an alternative to using `custom_domain_certificate_key_vault_url` for direct certificate upload.

If using Key Vault reference, leave this as null and use `custom_domain_certificate_key_vault_url` instead.
DESCRIPTION
  sensitive   = true
}

variable "managed_certificates" {
  type = map(object({
    subject_name              = string
    domain_control_validation = optional(string, "HTTP")

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of managed certificates to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

Managed certificates are auto-provisioned and auto-renewed by Azure.

- `subject_name` - (Required) The subject name (domain name) for the certificate.
- `domain_control_validation` - (Optional) The domain control validation method. Possible values: 'CNAME', 'HTTP', 'TXT'. Defaults to 'HTTP'.

---
`timeouts` block supports the following:
- `create` - (Defaults to 30 minutes) Used when creating the managed certificate.
- `delete` - (Defaults to 30 minutes) Used when deleting the managed certificate.
- `read` - (Defaults to 5 minutes) Used when retrieving the managed certificate.
- `update` - (Defaults to 30 minutes) Used when updating the managed certificate.

Example:
```
managed_certificates = {
  "my-domain-cert" = {
    subject_name              = "example.com"
    domain_control_validation = "HTTP"
  }
}
```
DESCRIPTION
  nullable    = false
}

variable "peer_traffic_encryption_enabled" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Enable peer-to-peer traffic encryption within the Container Apps environment.

When enabled, all network traffic between apps within the environment is encrypted using private certificates managed by Azure.

This is different from `peer_authentication_enabled` (mTLS):
- `peer_authentication_enabled` - Enables mutual TLS authentication (who you are)
- `peer_traffic_encryption_enabled` - Enables traffic encryption (secure channel)

Both can be enabled independently or together.

**Note:** Enabling peer-to-peer encryption may increase response latency and reduce maximum throughput in high-load scenarios.

Defaults to `false`.
DESCRIPTION
  nullable    = false
}
