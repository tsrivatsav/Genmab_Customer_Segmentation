output "s3_bucket_name" {
  description = "The name of the S3 bucket created for SageMaker artifacts."
  value       = aws_s3_bucket.sagemaker_bucket.bucket
}

output "sagemaker_endpoint_name" {
  description = "The name of the deployed SageMaker endpoint."
  value       = aws_sagemaker_endpoint.segmentation_endpoint.name
}

output "sagemaker_iam_role_arn" {
  description = "The ARN of the IAM role created for SageMaker."
  value       = aws_iam_role.sagemaker_role.arn
}