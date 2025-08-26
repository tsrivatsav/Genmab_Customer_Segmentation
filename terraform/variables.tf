variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A unique prefix for naming resources."
  type        = string
  default     = "genmab-takehome"
}

variable "segmentation_image_uri" {
  description = "Docker image URI for the SageMaker Scikit-learn container."
  type        = string
  default     = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1-cpu-py3"
}

variable "segmentation_model_data_path" {
  description = "S3 path to the segmentation model.tar.gz file."
  type        = string
  default     = "s3://genmab-assessment/customer-segmentation/model.tar.gz"
}