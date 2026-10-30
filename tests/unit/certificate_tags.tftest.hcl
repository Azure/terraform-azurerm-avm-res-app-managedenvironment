# Uses the real AzAPI provider (no mock) at plan time so its argument validation runs.
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
  enable_telemetry = false
  location         = "swedencentral"
  name             = "example-certificate"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test"
  certificate_key_vault_properties = {
    identity      = "System"
    key_vault_url = "https://kv-test.vault.azure.net/secrets/example-certificate"
  }
}

run "certificate_with_tags_plans" {
  command = plan

  module {
    source = "./modules/certificates"
  }

  variables {
    tags = {
      environment = "test"
    }
  }

  assert {
    condition     = azapi_resource.this.tags == tomap({ environment = "test" })
    error_message = "Certificate tags should be set on the azapi_resource tags argument."
  }

  assert {
    condition     = !contains(keys(azapi_resource.this.body), "tags")
    error_message = "Certificate tags must not also be set inside body (AzAPI rejects tags in both places)."
  }
}

run "certificate_without_tags_plans" {
  command = plan

  module {
    source = "./modules/certificates"
  }

  assert {
    condition     = azapi_resource.this.name == "example-certificate"
    error_message = "A certificate without tags should still plan."
  }
}

run "managed_certificate_with_tags_plans" {
  command = plan

  module {
    source = "./modules/managed_certificates"
  }

  variables {
    name                      = "example-managed-certificate"
    domain_control_validation = "CNAME"
    subject_name              = "app.example.com"
    tags = {
      environment = "test"
    }
  }

  assert {
    condition     = azapi_resource.this.tags == tomap({ environment = "test" })
    error_message = "Managed certificate tags should be set on the azapi_resource tags argument."
  }

  assert {
    condition     = !contains(keys(azapi_resource.this.body), "tags")
    error_message = "Managed certificate tags must not also be set inside body (AzAPI rejects tags in both places)."
  }
}
