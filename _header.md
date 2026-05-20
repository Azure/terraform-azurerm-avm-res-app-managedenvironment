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

> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>
