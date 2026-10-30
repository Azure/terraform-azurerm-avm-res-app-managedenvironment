locals {
  resource_body = {
    name = var.name
    properties = {
      domainControlValidation = var.domain_control_validation
      subjectName             = var.subject_name
    }
  }
}
