# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.4"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.52"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
