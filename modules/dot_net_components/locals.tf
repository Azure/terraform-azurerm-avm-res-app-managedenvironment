locals {
  resource_body = {
    name = var.name
    properties = {
      componentType = var.component_type
      configurations = var.configurations == null ? null : [for item in var.configurations : item == null ? null : {
        propertyName = item.property_name
        value        = item.value
      }]
      serviceBinds = var.service_binds == null ? null : [for item in var.service_binds : item == null ? null : {
        name      = item.name
        serviceId = item.service_id
      }]
    }
  }
}
