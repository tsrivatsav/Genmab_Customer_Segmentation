# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "${var.project_name}-sagemaker-role"

  # This trust policy allows the SageMaker service to assume this role.
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the main SageMaker policy.
resource "aws_iam_role_policy_attachment" "sagemaker_policy_attach" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Attach the S3 Full Access policy.
resource "aws_iam_role_policy_attachment" "s3_full_access_attach" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# A random suffix to ensure the S3 bucket name is unique
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for data and model artifacts
resource "aws_s3_bucket" "sagemaker_bucket" {
  bucket = "${var.project_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# 1. SageMaker Model
resource "aws_sagemaker_model" "segmentation_model" {
  name               = "${var.project_name}-model"
  execution_role_arn = aws_iam_role.sagemaker_role.arn

  primary_container {
    image          = var.sagemaker_image_uri
    model_data_url = var.model_data_s3_path

    environment = {
      SAGEMAKER_PROGRAM = "inference.py"
      SAGEMAKER_SUBMIT_DIRECTORY = var.model_data_s3_path
    }
  }

  tags = {
    Name = "${var.project_name}-model"
  }

  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_policy_attach,
    aws_iam_role_policy_attachment.s3_full_access_attach,
  ]
}



# 2. SageMaker Endpoint Configuration
resource "aws_sagemaker_endpoint_configuration" "segmentation_endpoint_config" {
  name = "${var.project_name}-endpoint-config"

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.segmentation_model.name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium" # Choose an appropriate instance type
  }

  tags = {
    Name = "${var.project_name}-endpoint-config"
  }
}

# 3. SageMaker Endpoint
resource "aws_sagemaker_endpoint" "segmentation_endpoint" {
  name                 = "${var.project_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.segmentation_endpoint_config.name

  tags = {
    Name = "${var.project_name}-endpoint"
  }
}