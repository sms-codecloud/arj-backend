provider "aws" {
  region = var.aws_region
  # Credentials provided via environment variables injected by Jenkins.
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "hello-dotnet-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello" {
  filename         = var.lambda_zip
  function_name    = "hello-dotnet-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "HelloWorld::Function::FunctionHandler"
  runtime          = "dotnet8"
  source_code_hash = filebase64sha256(var.lambda_zip)
  publish          = true
  timeout          = 10
  memory_size      = 128
}
