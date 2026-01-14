provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36"
    }
  }
}
