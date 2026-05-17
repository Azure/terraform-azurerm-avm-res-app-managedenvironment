# Upgrade Guide

This document describes adopter-facing changes when upgrading this module between versions.

It is intentionally focused on migration work you may need to do in your configuration. New functionality belongs in release notes and is not repeated here.

---

## 0.4.0 to 0.5.0 (Unreleased)

### What is handled automatically

The following changes are handled by compatibility shims or `moved` blocks and do **not** require immediate action:

- singular submodule addresses renamed to plural:
  - `module.certificate` -> `module.certificates`
  - `module.dapr_component` -> `module.dapr_components`
  - `module.managed_certificate` -> `module.managed_certificates`
  - `module.storage` -> `module.storages`
- legacy root variables that now map to newer nested inputs still continue to work for now through deprecation fallbacks

You should still migrate off deprecated inputs over time, but they are not the primary breaking item in this upgrade.

### Main migration work

The main adopter-visible changes in this upgrade are schema changes in child-resource maps and the introduction of write-only values with version trackers.

#### 1. Storage definitions are now nested

The `storages` input no longer uses the older flat shape. Azure Files settings now live under `azure_file`, and the storage account key is modeled separately with a version tracker.

**Before:**

```hcl
storages = {
  "my-storage" = {
    access_key   = "..."
    access_mode  = "ReadWrite"
    account_name = "mystorageaccount"
    share_name   = "myshare"
  }
}
```

**After:**

```hcl
storages = {
  "my-storage" = {
    name = "my-storage"

    azure_file = {
      access_mode  = "ReadWrite"
      account_name = "mystorageaccount"
      share_name   = "myshare"
    }

    account_key         = "..."
    account_key_version = 1
  }
}
```

#### 2. Dapr component secrets and version fields changed shape

The `dapr_components` input now uses:

- `dapr_components_version` instead of `version`
- `secrets` instead of `secret`
- `secrets_version` for write-only secret updates

**Before:**

```hcl
dapr_components = {
  "my-component" = {
    component_type = "state.redis"
    version        = "v1"
    secret = [{
      name  = "redis-password"
      value = "..."
    }]
  }
}
```

**After:**

```hcl
dapr_components = {
  "my-component" = {
    name                    = "my-component"
    component_type          = "state.redis"
    dapr_components_version = "v1"
    secrets = [{
      name  = "redis-password"
      value = "..."
    }]
    secrets_version = 1
  }
}
```

#### 3. Certificates now use the AzAPI-oriented schema

The `certificates` input has been restructured around the AzAPI body shape.

The main changes are:

- `name` and `location` are now explicit
- uploaded certificate values are modeled as `password` / `value`
- write-only certificate data now uses version trackers
- Key Vault references now sit under `certificate_key_vault_properties`

**Before:**

```hcl
certificates = {
  "my-cert" = {
    certificate_password = "..."
    certificate_value    = "..."
  }
}
```

**After:**

```hcl
certificates = {
  "my-cert" = {
    name             = "my-cert"
    location         = "eastus"
    password         = "..."
    password_version = 1
    value            = "..."
    value_version    = 1

    certificate_key_vault_properties = {
      identity      = "..."
      key_vault_url = "..."
    }
  }
}
```

#### 4. Managed certificates now require explicit resource metadata

The `managed_certificates` input now includes `name` and `location` in each entry.

**Before:**

```hcl
managed_certificates = {
  "my-cert" = {
    subject_name              = "example.com"
    domain_control_validation = "HTTP"
  }
}
```

**After:**

```hcl
managed_certificates = {
  "my-cert" = {
    name                      = "my-cert"
    location                  = "eastus"
    subject_name              = "example.com"
    domain_control_validation = "HTTP"
  }
}
```

### Write-only values and version trackers

Several sensitive values are now modeled as write-only inputs. When you use them, you must also set the corresponding version tracker and increment that version when the secret value changes.

| Write-only value | Version tracker |
|---|---|
| `shared_key` | `shared_key_version` |
| `certificate_password` | `certificate_password_version` |
| `certificate_value` | `certificate_value_version` |
| `dapr_ai_connection_string` | `dapr_ai_connection_string_version` |
| `dapr_ai_instrumentation_key` | `dapr_ai_instrumentation_key_version` |
| `account_key` | `account_key_version` |
| `secrets` | `secrets_version` |

### Deprecated inputs you should plan to migrate

The older root inputs below still have compatibility handling in this branch, but should be treated as deprecated migration paths rather than long-term configuration:

- `zone_redundancy_enabled` -> `zone_redundant`
- `workload_profile` -> `workload_profiles`
- `peer_authentication_enabled` -> `peer_authentication`
- `peer_traffic_encryption_enabled` -> `peer_traffic_configuration`
- `public_network_access_enabled` -> `public_network_access`
- `internal_load_balancer_enabled` -> `vnet_configuration.internal`
- `infrastructure_subnet_id` -> `vnet_configuration.infrastructure_subnet_id`
- `infrastructure_resource_group_name` -> `infrastructure_resource_group`
- `custom_domain_dns_suffix` -> `custom_domain_configuration.dns_suffix`
- `custom_domain_certificate_key_vault_url` -> `custom_domain_configuration.certificate_key_vault_properties.key_vault_url`
- `custom_domain_certificate_key_vault_identity` -> `custom_domain_configuration.certificate_key_vault_properties.identity`
- `custom_domain_certificate_value` -> `custom_domain_configuration.certificate_value`
- `log_analytics_workspace_customer_id` -> `app_logs_configuration.log_analytics_configuration.customer_id`
- `log_analytics_workspace_destination` -> `app_logs_configuration.destination`
- `log_analytics_workspace_primary_shared_key` -> `shared_key`

### Provider / API changes

- AzAPI provider requirement is now `~> 2.7`
- The root managed environment resource now uses `Microsoft.App/managedEnvironments@2025-10-02-preview`

---
