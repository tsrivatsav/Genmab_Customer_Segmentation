output "segmentation_endpoint_name" {
  description = "The name of the deployed SageMaker endpoint for customer segmentation."
  value       = aws_sagemaker_endpoint.segmentation_endpoint.name
}

output "generative_ai_endpoint_name" {
  description = "The name of the deployed SageMaker endpoint for the Generative AI model."
  value       = aws_sagemaker_endpoint.genai_endpoint.name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket created for model artifacts."
  value       = aws_s3_bucket.sagemaker_bucket.bucket
}

output "sagemaker_iam_role_arn" {
  description = "The ARN of the IAM role created for SageMaker."
  value       = aws_iam_role.sagemaker_role.arn
}

output "generative_api_endpoint_url" {
  description = "The URL of the deployed Lambda API Gateway endpoint."
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/summarize"
}