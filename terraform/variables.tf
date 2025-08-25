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

# --- Variables for Task 2: Segmentation Model ---
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


# --- Variables for Task 3: Generative AI Model ---
variable "genai_image_uri" {
  description = "Docker image URI for the SageMaker PyTorch container."
  type        = string
  default     = "763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:1.13.1-cpu-py39-ubuntu20.04-sagemaker"
}

variable "genai_model_data_path" {
  description = "S3 path to the fine-tuned genai model.tar.gz file."
  type        = string
  default     = "s3://genmab-assessment/gen-ai/model.tar.gz"
}