

resource "aws_iam_role" "lambda_exec" {
  name = "hello_world_lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect   = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello" {
  function_name    = "hello_world_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  filename         = var.lambda_zip
  source_code_hash = filebase64sha256(var.lambda_zip)
  publish          = true
  timeout          = 10
  memory_size      = 128
}

output "lambda_name" {
  value = aws_lambda_function.hello.function_name
}
