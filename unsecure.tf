provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  region     = "us-west-2"
}

resource "aws_security_group_rule" "my-rule" {
    type        = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_alb_listener" "my-alb-listener"{
    port     = "80"
    protocol = "HTTP"
}

resource "azurerm_managed_disk" "source" {
    encryption_settings {
        enabled = var.enableEncryption
    }
}

resource "aws_api_gateway_domain_name" "outdated_security_policy" {
    security_policy = "TLS_1_0"
}

resource "aws_api_gateway_domain_name" "valid_security_policy" {
    security_policy = "TLS_1_2"
}

variable "enableEncryption" {
    default = false
}
