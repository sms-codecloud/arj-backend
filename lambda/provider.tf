terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = var.s3_bucket
    key    = "terraform/state"
    region = var.aws_region
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}