# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.5"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.53"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
