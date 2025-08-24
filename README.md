# SageMaker Customer Segmentation - Infrastructure

This folder contains the Terraform scripts to automatically provision the necessary AWS infrastructure for the customer segmentation model, as required by Task 2.

## Prerequisites

1.  **Terraform**: You must have Terraform installed on your local machine.
2.  **AWS CLI**: You must have the AWS CLI installed and configured with the necessary credentials for your AWS account.

## How to Deploy the Infrastructure

1.  **Initialize Terraform**:
    Open your terminal, navigate to this directory, and run the following command to initialize the Terraform providers.
    ```bash
    terraform init
    ```

2.  **Apply the Configuration**:
    Run the following command to create all the AWS resources (S3 bucket, IAM role, and SageMaker endpoint). Type `yes` when prompted to confirm.
    ```bash
    terraform apply
    ```
    Upon successful completion, Terraform will output the names of the created resources.

## How to Destroy the Infrastructure

1.  **Tear Down Resources**:
    To avoid ongoing costs, run the following command to delete all resources created by this script. Type `yes` when prompted to confirm.
    ```bash
    terraform destroy
    ```