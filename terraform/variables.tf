variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

# Define a project name prefix for unique resource names
variable "project_name" {
  description = "A unique prefix for naming resources."
  type        = string
  default     = "genmab-customer-segmentation-project"
}

# The ECR image URI for the SageMaker algorithm container
variable "sagemaker_image_uri" {
  description = "Docker image URI for the SageMaker Scikit-learn container."
  type        = string
  default     = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1-cpu-py3"
}

# The S3 path to your trained model artifacts from Task 1
variable "model_data_s3_path" {
  description = "The S3 path to the model.tar.gz file."
  type        = string
  default     = "s3://genmab-assessment/customer-segmentation/model.tar.gz"
}