terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10.0"
    }
  }
  backend "s3" {
    bucket = "arj-terraform-state"
    key    = "terraform/state/lambda/terraform.tfstate"
    region = var.aws_region
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}