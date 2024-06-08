# provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    }
  }

  required_version = ">= 1.7.5"
}


# Specify the provider and access details
provider "aws" {
  region        = var.aws_region
}