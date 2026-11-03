# Uses the real AzAPI provider (no mock) at plan time so its embedded schema validation runs.
# No Azure credentials are needed because nothing is read or created.
provider "azapi" {
  subscription_id            = "00000000-0000-0000-0000-000000000000"
  tenant_id                  = "00000000-0000-0000-0000-000000000001"
  client_id                  = "00000000-0000-0000-0000-000000000002"
  client_secret              = "not-a-real-secret"
  skip_provider_registration = true
  use_cli                    = false
}

variables {
  component_type = "secretstores.azure.keyvault"
  location       = "australiaeast"
  name           = "secretstore"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test"
}

run "secrets_pass_arm_schema_validation" {
  command = plan

  module {
    source = "./modules/dapr_components"
  }

  variables {
    secrets = [
      {
        name  = "plain-secret"
        value = "value"
      },
      {
        name          = "kv-secret"
        identity      = "system"
        key_vault_url = "https://kv-test.vault.azure.net/secrets/kv-secret"
      },
    ]
    secrets_version = 1
  }

  assert {
    condition     = azapi_resource.this.name == "secretstore"
    error_message = "The Dapr component with secrets should plan without schema validation errors."
  }
}
