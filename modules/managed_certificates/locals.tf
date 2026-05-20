locals {
  resource_body = {
    name = var.name
    properties = {
      domainControlValidation = var.domain_control_validation
      subjectName             = var.subject_name
    }
    tags = var.tags == null ? null : { for k, value in var.tags : k => value }
  }
}
