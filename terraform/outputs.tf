output "lambda_arn" {
  value = aws_lambda_function.hello.arn
}

output "lambda_name" {
  value = aws_lambda_function.hello.function_name
}

output "http_api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}