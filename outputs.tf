# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs

output "resource" {
  description = "The Container Apps Managed Environment resource."
  value = {
    # azapi_resource.this_environment
    id = azapi_resource.this_environment.id
    #default_domain
    docker_bridge_cidr               = jsondecode(azapi_resource.this_environment).properties.vnetConfiguration.dockerBridgeCidr
    platform_reserved_cidr           = jsondecode(azapi_resource.this_environment).properties.vnetConfiguration.platformReservedCidr
    platform_reserved_dns_ip_address = jsondecode(azapi_resource.this_environment).properties.vnetConfiguration.platformReservedDnsIP
    #static_ip_address 
  }
}

output "id" {
  description = "The ID of the resource."
  value       = azapi_resource.this_environment.id
}

output "name" {
  description = "The name of the resource"
  value       = azapi_resource.this_environment.name
}
