variable "http_route_configs" {
  type = map(object({
    custom_domains = optional(list(object({
      binding_type   = optional(any)
      certificate_id = optional(string)
      name           = string
    })))
    name = string
    rules = optional(list(object({
      description = optional(string)
      routes = optional(list(object({
        action = optional(object({
          prefix_rewrite = optional(string)
        }))
        match = optional(object({
          case_sensitive        = optional(bool)
          path                  = optional(string)
          path_separated_prefix = optional(string)
          prefix                = optional(string)
        }))
      })))
      targets = optional(list(object({
        container_app = string
        label         = optional(string)
        revision      = optional(string)
      })))
    })))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of HTTP route configurations to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each HTTP route configuration supports the following:

- `name` - (Required) The name of the HTTP route configuration resource.
- `custom_domains` - (Optional) Custom domain bindings for the HTTP route hostnames.
- `rules` - (Optional) Routing rules for the HTTP route configuration.
DESCRIPTION
}
