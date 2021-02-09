# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.6"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.55"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
