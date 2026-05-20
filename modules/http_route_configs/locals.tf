locals {
  resource_body = {
    name = var.name
    properties = {
      customDomains = var.custom_domains == null ? null : [for item in var.custom_domains : item == null ? null : {
        bindingType   = item.binding_type
        certificateId = item.certificate_id
        name          = item.name
      }]
      rules = var.rules == null ? null : [for item in var.rules : item == null ? null : {
        description = item.description
        routes = item.routes == null ? null : [for item in item.routes : item == null ? null : {
          action = item.action == null ? null : {
            prefixRewrite = item.action.prefix_rewrite
          }
          match = item.match == null ? null : {
            caseSensitive       = item.match.case_sensitive
            path                = item.match.path
            pathSeparatedPrefix = item.match.path_separated_prefix
            prefix              = item.match.prefix
          }
        }]
        targets = item.targets == null ? null : [for item in item.targets : item == null ? null : {
          containerApp = item.container_app
          label        = item.label
          revision     = item.revision
          weight       = item.weight
        }]
      }]
    }
  }
}
