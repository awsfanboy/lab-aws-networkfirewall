provider "aws" {
  profile = var.aws_profile
  region  = var.region

}

terraform {
  required_version = ">= 1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.49"
    }
  }
}