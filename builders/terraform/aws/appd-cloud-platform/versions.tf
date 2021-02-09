# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.6"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.27"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
