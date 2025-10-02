terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10.0"
    }
  }
  backend "s3" {
    bucket = "arj-bootcamp"
    key    = "terraform/state/arj-backend/terraform.tfstate"
    region = "ap-south-1"
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}