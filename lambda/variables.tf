variable "aws_region" {
  type        = string
  description = "AWS region"
  default = "ap-south-1"
}

variable "lambda_zip" {
  type        = string
  description = "Absolute path to the built lambda zip"
}

variable "lambda_runtime" {
  type    = string
  default = "dotnet8"
}

variable "lambda_handler" {
  type    = string
  default = "hello_world::Function::FunctionHandler"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket for terraform state"
  default     = "arj-terraform-state"
}
