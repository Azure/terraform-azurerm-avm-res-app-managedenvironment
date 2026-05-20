# These moved blocks allow existing Terraform state to be upgraded without destroying
# and recreating resources. Each block maps the old resource/module address to the new one.
#
# For-each modules: a single moved block covers all instances automatically
# (Terraform expands module.old[*] → module.new[*]).
#
# Submodule renames: singular names were changed to plural for consistency.

moved {
  from = module.certificate
  to   = module.certificates
}

moved {
  from = module.dapr_component
  to   = module.dapr_components
}

moved {
  from = module.managed_certificate
  to   = module.managed_certificates
}

moved {
  from = module.storage
  to   = module.storages
}
