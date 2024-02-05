output "app_environment" {
  description = "The outputs for the managed environment, this allows outputs to be inspected in the CI run."
  value       = module.managedenvironment.resource
}
