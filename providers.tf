provider "aws" {
  region  = var.region
  version = "~> 4.0"
}

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}