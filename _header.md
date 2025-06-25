# Azure Container Apps Managed Environment Module

This module is used to manage Container Apps Managed Environments.

This module is composite and includes sub modules that can be used independently for deploying sub resources. These are:

- **dapr_component** - creation of Dapr components.
- **storage** - presentation of Azure Files Storage.

## OpenTofu Compatibility

This module supports OpenTofu version 1.9+ through dedicated `.tofu` files that provide compatibility shims:

- **terraform.tofu** - Allows OpenTofu 1.9+ (while terraform.tf requires 1.10+ for ephemeral resources)
- **locals.tofu** - Uses `data` resources instead of `ephemeral` resources for OpenTofu compatibility
- **modules/*/terraform.tofu** - Module-specific OpenTofu configuration

When using OpenTofu, these `.tofu` files will be automatically used instead of their `.tf` counterparts, providing the same functionality without requiring ephemeral resource support.

> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>
