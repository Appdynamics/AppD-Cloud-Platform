# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.64"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
