# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.1"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.51"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
