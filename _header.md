# Azure Container Apps Managed Environment Module

This module is used to manage Container Apps Managed Environments.

This module is composite and includes submodules that can be used independently for deploying sub-resources. These are:

- **certificates** - creation of environment certificates.
- **dapr_components** - creation of Dapr components.
- **dapr_subscriptions** - creation of Dapr subscriptions.
- **dot_net_components** - creation of .NET components.
- **http_route_configs** - creation of HTTP route configurations.
- **java_components** - creation of Java components.
- **maintenance_configurations** - creation of maintenance configurations.
- **managed_certificates** - creation of managed certificates.
- **storages** - presentation of Azure Files storage.

## Upgrading from 0.5.x or earlier

The lock, role assignments and diagnostic settings are now AzAPI resources, and the module no longer uses the AzureRM provider. `moved` blocks carry them, and the environment, to their new addresses in the state, so nothing is recreated. No input changes are needed.

1. A `ReadOnly` lock blocks the upgrade, because the role assignments and diagnostic settings are updated. Change it to `CanNotDelete`, or remove it, until the upgrade is applied.
1. Cross-tenant role assignments, which set `delegated_managed_identity_resource_id`, need extra steps. The AzureRM provider stored their ID with a `|<tenant-id>` suffix that the `moved` block cannot convert. Before planning, remove each one from the state, then import it at its new address with an `import` block in your root module:

   ```pwsh
   terraform state rm 'module.<module-name>.azurerm_role_assignment.this["<key>"]'
   ```

   ```hcl
   import {
     to = module.<module-name>.azapi_resource.role_assignments["<key>"]
     id = "<role assignment resource ID, without the |<tenant-id> suffix>"
   }
   ```

1. Run `terraform init -upgrade`, then `terraform plan`. The plan must not destroy or replace anything except the AVM telemetry deployments, which are replaced whenever the module version changes. It moves the environment without changes, updates the lock, role assignments and diagnostic settings in place with the same settings, and adds:
   - a `random_uuid` for each role assignment, which only exists in the state. The assignments keep their names;
   - `time_sleep.lock_removal`, when a lock is set;
   - the interfaces utility module's telemetry resources, when telemetry is enabled.

   Child resources, such as Dapr components and storages, are updated in place to record the `retry` setting they now share with the environment. Only the state changes; nothing is sent to Azure.

Other changes:

- `resource_types`, `retry` and `ignore_body_changes` cover the environment, its lock, role assignments and diagnostic settings, and each submodule. `retry` retries `ContainerAppEnvironmentDisabled` by default, as the environment always did, and now applies to the child resources too. `timeouts` now applies to every resource.
- `lock` accepts `notes`, and `role_assignments` accepts `name`.
- Role names are matched, ignoring case, against the role definitions that can be assigned in the resource group, and an unknown name fails during plan. Use the ID of a custom role that can only be assigned on the environment.

> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>
