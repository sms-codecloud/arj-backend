variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "dotnetcore3.1"
}

variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "HelloWorld::HelloWorld.Function::FunctionHandler"
}

variable "s3_bucket" {
  description = "The S3 bucket where the Lambda deployment package will be stored"
  type        = string
}

variable "s3_key" {
  description = "The S3 key for the Lambda deployment package"
  type        = string
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "lambda_zip" {
  description = "Absolute path to the lambda packaged zip file on the local filesystem"
  type        = string
}