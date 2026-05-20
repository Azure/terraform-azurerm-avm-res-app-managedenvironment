locals {
  resource_body = {
    name = var.name
    properties = {
      componentType = var.component_type
      configurations = var.configurations == null ? null : [for item in var.configurations : item == null ? null : {
        propertyName = item.property_name
        value        = item.value
      }]
      ingress = var.ingress == null ? null : {}
      scale = var.scale == null ? null : {
        maxReplicas = var.scale.max_replicas
        minReplicas = var.scale.min_replicas
      }
      serviceBinds = var.service_binds == null ? null : [for item in var.service_binds : item == null ? null : {
        name      = item.name
        serviceId = item.service_id
      }]
      springCloudGatewayRoutes = var.spring_cloud_gateway_routes == null ? null : [for item in var.spring_cloud_gateway_routes : item == null ? null : {
        filters    = item.filters == null ? null : [for f in item.filters : f]
        id         = item.id
        order      = item.order
        predicates = item.predicates == null ? null : [for p in item.predicates : p]
        uri        = item.uri
      }]
    }
  }
}
