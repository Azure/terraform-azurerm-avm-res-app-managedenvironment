# Consumption workload profile with integrated vnet

This deploys a Container Apps Managed Environment using the consumption-based workload profile, using vnet integration and an external load balancer.

To modify this to use an internal load balancer, set the following parameter: `vnet_internal_only = true`.

This will create an additional resource group for platform managed resources that is prefixed with "ME-".  To choose a different name, set the parameter: `infrastructure_resource_group_name`.
