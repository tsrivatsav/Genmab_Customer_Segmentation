# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "${var.project_name}-sagemaker-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "sagemaker.amazonaws.com" }
    }]
  })
}

# Attach necessary policies
resource "aws_iam_role_policy_attachment" "sagemaker_policy_attach" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
resource "aws_iam_role_policy_attachment" "s3_full_access_attach" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# S3 bucket for data and model artifacts (reused by both)
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
resource "aws_s3_bucket" "sagemaker_bucket" {
  bucket = "${var.project_name}-${random_string.bucket_suffix.result}"
  tags   = { Name = "${var.project_name}-bucket" }
}

# =======================================================
# TASK 2: Customer Segmentation Endpoint
# =======================================================

resource "aws_sagemaker_model" "segmentation_model" {
  name = "${var.project_name}-segmentation-model"
  execution_role_arn = aws_iam_role.sagemaker_role.arn
  primary_container {
    image = var.segmentation_image_uri
    model_data_url = var.segmentation_model_data_path
    environment = {
      SAGEMAKER_PROGRAM = "inference.py"
      SAGEMAKER_SUBMIT_DIRECTORY = var.segmentation_model_data_path
    }
  }
  tags = { Task = "Customer Segmentation" }
  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_policy_attach,
    aws_iam_role_policy_attachment.s3_full_access_attach,
  ]
}

resource "aws_sagemaker_endpoint_configuration" "segmentation_endpoint_config" {
  name = "${var.project_name}-segmentation-endpoint-config"
  production_variants {
    variant_name = "AllTraffic"
    model_name = aws_sagemaker_model.segmentation_model.name
    initial_instance_count = 1
    instance_type = "ml.t2.medium"
  }
  tags = { Task = "Customer Segmentation" }
}

resource "aws_sagemaker_endpoint" "segmentation_endpoint" {
  name = "${var.project_name}-segmentation-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.segmentation_endpoint_config.name
  tags = { Task = "Customer Segmentation" }
}

# =======================================================
# TASK 3: Generative AI Endpoint
# =======================================================

resource "aws_sagemaker_model" "genai_model" {
  name = "${var.project_name}-genai-model"
  execution_role_arn = aws_iam_role.sagemaker_role.arn
  primary_container {
    image = var.genai_image_uri
    model_data_url = var.genai_model_data_path
    environment = {
      SAGEMAKER_PROGRAM = "inference.py"
      SAGEMAKER_SUBMIT_DIRECTORY = var.genai_model_data_path
    }
  }
  tags = { Task = "Generative AI" }
  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_policy_attach,
    aws_iam_role_policy_attachment.s3_full_access_attach,
  ]
}

resource "aws_sagemaker_endpoint_configuration" "genai_endpoint_config" {
  name = "${var.project_name}-genai-endpoint-config"
  production_variants {
    variant_name = "AllTraffic"
    model_name = aws_sagemaker_model.genai_model.name
    initial_instance_count = 1
    instance_type = "ml.t2.medium"
  }
  tags = { Task = "Generative AI" }
}

resource "aws_sagemaker_endpoint" "genai_endpoint" {
  name = "${var.project_name}-genai-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.genai_endpoint_config.name
  tags = { Task = "Generative AI" }
}