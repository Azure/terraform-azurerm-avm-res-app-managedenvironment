# Each submodule is tested on its own. The root passes each submodule its slot of `resource_types`,
# whose attribute is null unless overridden, so these runs pass null to prove that the submodule's own
# default applies.
mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test/children/child-test"
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      tenant_id                = "00000000-0000-0000-0000-000000000001"
    }
  }
}

variables {
  location  = "australiaeast"
  name      = "child-test"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test"
}

run "certificates" {
  command = apply

  module {
    source = "./modules/certificates"
  }

  variables {
    resource_types = {
      app_managed_environments_certificates = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/certificates@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The certificate should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The certificate should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "dapr_components" {
  command = apply

  module {
    source = "./modules/dapr_components"
  }

  variables {
    component_type = "state.azure.blobstorage"
    resource_types = {
      app_managed_environments_dapr_components = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/daprComponents@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The Dapr component should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The Dapr component should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "dapr_subscriptions" {
  command = apply

  module {
    source = "./modules/dapr_subscriptions"
  }

  variables {
    pubsub_name = "pubsub"
    topic       = "orders"
    resource_types = {
      app_managed_environments_dapr_subscriptions = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/daprSubscriptions@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The Dapr subscription should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The Dapr subscription should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "dot_net_components" {
  command = apply

  module {
    source = "./modules/dot_net_components"
  }

  variables {
    component_type = "AspireDashboard"
    resource_types = {
      app_managed_environments_dot_net_components = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/dotNetComponents@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The .NET component should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The .NET component should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "http_route_configs" {
  command = apply

  module {
    source = "./modules/http_route_configs"
  }

  variables {
    name = "routes"
    resource_types = {
      app_managed_environments_http_route_configs = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/httpRouteConfigs@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The HTTP route configuration should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The HTTP route configuration should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "java_components" {
  command = apply

  module {
    source = "./modules/java_components"
  }

  variables {
    component_type = "SpringBootAdmin"
    resource_types = {
      app_managed_environments_java_components = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/javaComponents@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The Java component should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The Java component should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "maintenance_configurations" {
  command = apply

  module {
    source = "./modules/maintenance_configurations"
  }

  variables {
    scheduled_entries = [
      {
        duration_hours = 8
        start_hour_utc = 2
        week_day       = "Sunday"
      }
    ]
    resource_types = {
      app_managed_environments_maintenance_configurations = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/maintenanceConfigurations@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The maintenance configuration should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The maintenance configuration should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "managed_certificates" {
  command = apply

  module {
    source = "./modules/managed_certificates"
  }

  variables {
    subject_name = "app.example.com"
    resource_types = {
      app_managed_environments_managed_certificates = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/managedCertificates@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The managed certificate should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The managed certificate should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "storages" {
  command = apply

  module {
    source = "./modules/storages"
  }

  variables {
    azure_file = {
      access_mode  = "ReadOnly"
      account_name = "sttest"
      share_name   = "share"
    }
    resource_types = {
      app_managed_environments_storages = null
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/storages@2025-10-02-preview" && azapi_resource.this.parent_id == var.parent_id
    error_message = "The storage should use its default resource type under the environment."
  }
  assert {
    condition     = contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The storage should retry ContainerAppEnvironmentDisabled by default."
  }
}

run "submodule_controls_are_honoured" {
  command = apply

  module {
    source = "./modules/storages"
  }

  variables {
    azure_file = {
      access_mode  = "ReadOnly"
      account_name = "sttest"
      share_name   = "share"
    }
    ignore_body_changes = {
      app_managed_environments_storages = ["properties.azureFile.accessMode"]
    }
    resource_types = {
      app_managed_environments_storages = "Microsoft.App/managedEnvironments/storages@2025-07-01"
    }
    retry = {
      error_message_regex = ["StorageAccountBusy"]
      interval_seconds    = 5
    }
    timeouts = {
      create = "45m"
    }
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments/storages@2025-07-01"
    error_message = "resource_types should override the API version."
  }
  assert {
    condition     = azapi_resource.this.retry.interval_seconds == 5 && azapi_resource.this.retry.error_message_regex == tolist(["StorageAccountBusy"])
    error_message = "retry should be passed through unchanged."
  }
  assert {
    condition     = azapi_resource.this.timeouts.create == "45m"
    error_message = "timeouts should be passed through."
  }
}

run "submodule_invalid_parent_id" {
  command = plan

  module {
    source = "./modules/storages"
  }

  variables {
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  }

  expect_failures = [var.parent_id]
}
