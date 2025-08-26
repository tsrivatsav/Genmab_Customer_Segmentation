# IAM Role for the Lambda Function
resource "aws_iam_role" "lambda_api_role" {
  name = "${var.project_name}-api-lambda-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Policy to allow Lambda to invoke the SageMaker endpoint
resource "aws_iam_policy" "sagemaker_invoke_policy" {
  name        = "${var.project_name}-sagemaker-invoke-policy"
  description = "Allows Lambda to invoke a SageMaker endpoint"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action   = "sagemaker:InvokeEndpoint",
      Effect   = "Allow",
      Resource = aws_sagemaker_endpoint.genai_endpoint.arn
    }]
  })
}

# Attach the policies to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sagemaker_attach" {
  role       = aws_iam_role.lambda_api_role.name
  policy_arn = aws_iam_policy.sagemaker_invoke_policy.arn
}
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attach" {
  role       = aws_iam_role.lambda_api_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda handler code into a zip file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../gen_ai_api/"
  output_path = "../gen_ai_api.zip"
}

# Define the Lambda Function Resource
resource "aws_lambda_function" "api_handler_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-api-handler"
  role             = aws_iam_role.lambda_api_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 120

  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = aws_sagemaker_endpoint.genai_endpoint.name
    }
  }
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
  integration_uri  = aws_lambda_function.api_handler_lambda.invoke_arn
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
  function_name = aws_lambda_function.api_handler_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

# Create a deployment for the API
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_apigatewayv2_route.api_route.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create a stage for the deployment
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id        = aws_apigatewayv2_api.lambda_api.id
  name          = "$default"
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
  auto_deploy   = true
}