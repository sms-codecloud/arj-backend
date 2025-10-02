variable "aws_region" {
  type        = string
  description = "AWS region"
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
