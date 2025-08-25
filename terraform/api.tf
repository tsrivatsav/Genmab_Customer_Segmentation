# IAM Role for the Lambda Function
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-api-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Attach the basic execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define the Lambda Function Resource
resource "aws_lambda_function" "generative_ai_lambda" {
  filename         = "../gen_ai_api/deployment_package.zip"
  function_name    = "${var.project_name}-summarizer-api"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 900  
  memory_size      = 1024 
}

# Define the API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
}

# Create the integration between API Gateway and Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.generative_ai_lambda.invoke_arn
}

# Define the API route (e.g., POST /summarize)
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /summarize"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Grant API Gateway permission to invoke the Lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generative_ai_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}