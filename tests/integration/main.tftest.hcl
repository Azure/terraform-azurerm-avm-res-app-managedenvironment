# The provider mocking mechanism cannot validate the ephemeral resource this module uses to read the
# Log Analytics shared key, so the root module is tested against Azure. Only the resource group is
# created; every run of the module is a plan.
run "setup" {
  module {
    source = "./tests/integration/setup"
  }
}

variables {
  name             = "cae-int-test"
  enable_telemetry = false
}

run "defaults" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/managedEnvironments@2025-10-02-preview"
    error_message = "The environment should use the default resource type."
  }
  assert {
    condition     = azapi_resource.this.parent_id == run.setup.resource_group_id && azapi_resource.this.location == run.setup.location
    error_message = "Without parent_id, the environment should be created in resource_group_name in the current subscription."
  }
  assert {
    condition     = length(azapi_resource.this.retry.error_message_regex) == 1 && contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled")
    error_message = "The environment should retry ContainerAppEnvironmentDisabled by default, as it always has."
  }
  assert {
    condition     = length(azapi_resource.lock) + length(azapi_resource.role_assignments) + length(azapi_resource.diagnostic_settings) + length(time_sleep.lock_removal) + length(data.azapi_resource_list.role_definitions) == 0
    error_message = "No interface resources should be created by default."
  }
  assert {
    condition     = output.name == "cae-int-test"
    error_message = "The name output should come from the environment."
  }
}

run "parent_id_takes_precedence" {
  command = plan

  variables {
    location            = run.setup.location
    parent_id           = run.setup.resource_group_id
    resource_group_name = "rg-not-used"
  }

  assert {
    condition     = azapi_resource.this.parent_id == run.setup.resource_group_id
    error_message = "parent_id should take precedence over resource_group_name."
  }
}

run "invalid_parent_id" {
  command = plan

  variables {
    location            = run.setup.location
    parent_id           = "/subscriptions/${run.setup.subscription_id}"
    resource_group_name = run.setup.resource_group_name
  }

  expect_failures = [var.parent_id]
}

run "controls_apply_to_every_resource" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    lock = {
      kind = "CanNotDelete"
    }
    role_assignments = {
      reader = {
        role_definition_id_or_name = "Reader"
        principal_id               = "22222222-2222-2222-2222-222222222222"
      }
    }
    diagnostic_settings = {
      law = {
        workspace_resource_id = "${run.setup.resource_group_id}/providers/Microsoft.OperationalInsights/workspaces/law-test"
      }
    }
    # The environment and diagnostic settings bodies use properties that only their default API
    # versions define, so the override is shown on the lock and role assignments.
    resource_types = {
      authorization_locks            = "Microsoft.Authorization/locks@2016-09-01"
      authorization_role_assignments = "Microsoft.Authorization/roleAssignments@2020-10-01-preview"
    }
    retry = {
      interval_seconds = 5
    }
    timeouts = {
      create = "45m"
    }
    ignore_body_changes = {
      app_managed_environments = ["properties.workloadProfiles"]
    }
  }

  assert {
    condition     = azapi_resource.lock[0].type == "Microsoft.Authorization/locks@2016-09-01" && azapi_resource.role_assignments["reader"].type == "Microsoft.Authorization/roleAssignments@2020-10-01-preview" && azapi_resource.this.type == "Microsoft.App/managedEnvironments@2025-10-02-preview"
    error_message = "resource_types should override only the API versions that are supplied."
  }
  assert {
    condition     = azapi_resource.this.retry.interval_seconds == 5 && contains(azapi_resource.this.retry.error_message_regex, "ContainerAppEnvironmentDisabled") && azapi_resource.lock[0].retry.interval_seconds == 5 && azapi_resource.role_assignments["reader"].retry.interval_seconds == 5 && azapi_resource.diagnostic_settings["law"].retry.interval_seconds == 5
    error_message = "retry should apply to every resource and keep the default error pattern when only the interval is overridden."
  }
  assert {
    condition     = azapi_resource.this.timeouts.create == "45m" && azapi_resource.lock[0].timeouts.create == "45m" && azapi_resource.role_assignments["reader"].timeouts.create == "45m" && azapi_resource.diagnostic_settings["law"].timeouts.create == "45m"
    error_message = "timeouts should apply to every resource."
  }
}

run "lock_keeps_the_legacy_notes" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    lock = {
      kind = "CanNotDelete"
    }
  }

  assert {
    condition     = azapi_resource.lock[0].name == "lock-CanNotDelete" && azapi_resource.lock[0].body.properties.level == "CanNotDelete"
    error_message = "The lock should get the default name."
  }
  assert {
    condition     = azapi_resource.lock[0].body.properties.notes == "Cannot delete the resource or its child resources."
    error_message = "The lock should keep the notes earlier versions wrote, so upgrades do not change it."
  }
  assert {
    condition     = time_sleep.lock_removal[0].destroy_duration == "30s"
    error_message = "Removing the lock should pause before the resources under it are deleted."
  }
}

run "read_only_lock_notes" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    lock = {
      kind = "ReadOnly"
    }
  }

  assert {
    condition     = azapi_resource.lock[0].name == "lock-ReadOnly" && azapi_resource.lock[0].body.properties.notes == "Cannot delete or modify the resource or its child resources."
    error_message = "A ReadOnly lock should keep the name and notes earlier versions wrote."
  }
}

run "lock_with_custom_name_and_notes" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    lock = {
      kind  = "ReadOnly"
      name  = "lock-custom"
      notes = "Managed by the platform team."
    }
  }

  assert {
    condition     = azapi_resource.lock[0].name == "lock-custom" && azapi_resource.lock[0].body.properties.notes == "Managed by the platform team."
    error_message = "Custom lock name and notes should be used."
  }
}

run "role_assignment_by_role_name" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    role_assignments = {
      reader = {
        role_definition_id_or_name       = "reader"
        principal_id                     = "22222222-2222-2222-2222-222222222222"
        skip_service_principal_aad_check = true
      }
    }
  }

  assert {
    condition     = azapi_resource.role_assignments["reader"].type == "Microsoft.Authorization/roleAssignments@2022-04-01" && azapi_resource.role_assignments["reader"].body.properties.principalId == "22222222-2222-2222-2222-222222222222"
    error_message = "The role assignment should use the default resource type and principal."
  }
  assert {
    condition     = lower(azapi_resource.role_assignments["reader"].body.properties.roleDefinitionId) == "/subscriptions/${run.setup.subscription_id}/providers/microsoft.authorization/roledefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    error_message = "The role name should be resolved to its role definition ID, ignoring case."
  }
  assert {
    condition     = azapi_resource.role_assignments["reader"].body.properties.principalType == "ServicePrincipal"
    error_message = "skip_service_principal_aad_check should send the ServicePrincipal principal type, as the AzureRM provider did."
  }
  assert {
    condition     = azapi_resource.role_assignments["reader"].replace_triggers_external_values.role_definition_id_or_name == "reader" && azapi_resource.role_assignments["reader"].replace_triggers_external_values.principal_id == "22222222-2222-2222-2222-222222222222"
    error_message = "Changing a role assignment input should replace the assignment, as it did with azurerm."
  }
  assert {
    condition     = data.azapi_resource_list.role_definitions[0].parent_id == run.setup.resource_group_id
    error_message = "Role definitions should be listed in the resource group, so the lookup does not wait for changes to the environment."
  }
}

run "role_assignment_by_tenant_level_id" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    role_assignments = {
      contributor = {
        role_definition_id_or_name = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        principal_id               = "22222222-2222-2222-2222-222222222222"
      }
    }
  }

  assert {
    condition     = azapi_resource.role_assignments["contributor"].body.properties.roleDefinitionId == "/subscriptions/${run.setup.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    error_message = "A tenant-level role definition ID should be qualified with the subscription, the form Azure returns."
  }
  assert {
    condition     = azapi_resource.role_assignments["contributor"].body.properties.principalType == null
    error_message = "The principal type should be left to Azure when it is not set."
  }
}

run "role_assignment_with_explicit_name" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    role_assignments = {
      reader = {
        name                       = "33333333-3333-3333-3333-333333333333"
        role_definition_id_or_name = "Reader"
        principal_id               = "22222222-2222-2222-2222-222222222222"
      }
    }
  }

  assert {
    condition     = azapi_resource.role_assignments["reader"].name == "33333333-3333-3333-3333-333333333333" && azapi_resource.role_assignments["reader"].replace_triggers_external_values.name == "33333333-3333-3333-3333-333333333333"
    error_message = "An explicit role assignment name should be used, and changing it should replace the assignment."
  }
}

run "role_assignment_with_unknown_role_name" {
  command = plan

  # The environment ID is unknown during this plan. Because role definitions are listed in the resource
  # group, the lookup still runs and the precondition fails during plan.
  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    role_assignments = {
      unknown = {
        role_definition_id_or_name = "Not A Real Role"
        principal_id               = "22222222-2222-2222-2222-222222222222"
      }
    }
  }

  expect_failures = [azapi_resource.role_assignments]
}

run "invalid_delegated_managed_identity" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    role_assignments = {
      reader = {
        role_definition_id_or_name             = "Reader"
        principal_id                           = "22222222-2222-2222-2222-222222222222"
        delegated_managed_identity_resource_id = "not-an-identity"
      }
    }
  }

  expect_failures = [var.role_assignments]
}

run "diagnostic_settings_mapping" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    diagnostic_settings = {
      law = {
        workspace_resource_id = "${run.setup.resource_group_id}/providers/Microsoft.OperationalInsights/workspaces/law-test"
      }
      event_hub = {
        name                                     = "diag-custom"
        event_hub_authorization_rule_resource_id = "${run.setup.resource_group_id}/providers/Microsoft.EventHub/namespaces/ehns-test/authorizationRules/RootManageSharedAccessKey"
        log_analytics_destination_type           = "AzureDiagnostics"
        log_categories                           = ["ContainerAppConsoleLogs"]
        log_groups                               = []
        metric_categories                        = []
      }
    }
  }

  assert {
    condition     = azapi_resource.diagnostic_settings["law"].name == "diag-cae-int-test" && azapi_resource.diagnostic_settings["event_hub"].name == "diag-custom"
    error_message = "Diagnostic settings should default their name."
  }
  assert {
    condition     = azapi_resource.diagnostic_settings["law"].body.properties.logAnalyticsDestinationType == null && azapi_resource.diagnostic_settings["event_hub"].body.properties.logAnalyticsDestinationType == "AzureDiagnostics"
    error_message = "Dedicated should be sent as null, as it always was, and AzureDiagnostics passed through."
  }
  assert {
    condition     = azapi_resource.diagnostic_settings["law"].body.properties.logs[0].categoryGroup == "allLogs" && azapi_resource.diagnostic_settings["event_hub"].body.properties.logs[0].category == "ContainerAppConsoleLogs"
    error_message = "Log categories and category groups should be mapped."
  }
  assert {
    condition     = azapi_resource.diagnostic_settings["law"].body.properties.metrics[0].category == "AllMetrics" && azapi_resource.diagnostic_settings["law"].body.properties.metrics[0].enabled
    error_message = "Metric categories should be enabled."
  }
  assert {
    condition     = !can(azapi_resource.diagnostic_settings["event_hub"].body.properties.metrics)
    error_message = "An empty metric_categories should send no metrics, because Azure would list every category as disabled."
  }
  assert {
    condition     = contains(azapi_resource.diagnostic_settings["law"].ignore_other_items_in_list, "properties.logs") && azapi_resource.diagnostic_settings["law"].list_unique_id_property["properties.logs"] == "category, categoryGroup"
    error_message = "Log items should be matched by category, so that the disabled category groups Azure returns are not reported as changes."
  }
}

run "submodules_are_created_under_the_environment" {
  command = plan

  variables {
    location            = run.setup.location
    resource_group_name = run.setup.resource_group_name
    dapr_components = {
      statestore = {
        name                    = "statestore"
        component_type          = "state.azure.blobstorage"
        dapr_components_version = "v1"
      }
    }
    storages = {
      share = {
        name = "share"
        azure_file = {
          access_mode  = "ReadOnly"
          account_name = "sttest"
          share_name   = "share"
        }
      }
    }
    lock = {
      kind = "CanNotDelete"
    }
  }

  assert {
    condition     = length(module.dapr_components) == 1 && module.dapr_components["statestore"].name == "statestore" && length(module.storages) == 1 && module.storages["share"].name == "share"
    error_message = "One submodule instance should be created for each child resource."
  }
  assert {
    condition     = length(time_sleep.lock_removal) == 1
    error_message = "The lock removal pause should be created alongside the lock."
  }
}
