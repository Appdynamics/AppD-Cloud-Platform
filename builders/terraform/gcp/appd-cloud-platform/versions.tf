# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.71, < 5.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
