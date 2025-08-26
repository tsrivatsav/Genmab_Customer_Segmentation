# Generative AI Integration with Transformers and AWS

This folder implements **Task 3** of the *R13306 Senior ML Engineer Technical Assessment*:  
> Integrate a Generative AI model (e.g., a Hugging Face transformer model) for generating insights from unstructured text data.

We use a **DistilBERT** model fine-tuned for sentiment analysis on customer reviews. The entire workflow, from fine-tuning to deploying the final serverless API, is managed within an AWS SageMaker Notebook, demonstrating a rapid, self-contained development and deployment cycle using the AWS SDK (Boto3).

---

## 📂 Project Structure
```
├── Reviews.csv                 # Input dataset for fine-tuning
├── fine_tune.ipynb     # Notebook for fine-tuning, deployment, and testing
├── source/                     # Directory for the training script
│   ├── train.py                # Fine-tuning script for SageMaker
│   └── requirements.txt        # Python dependencies for the training job
└── source_deploy/              # Directory for the inference script
├── inference.py            # Inference script for SageMaker endpoint
└── requirements.txt        # Python dependencies for the endpoint
```

---

## ⚙️ Steps Implemented

### 1. Environment Setup
- Launched a SageMaker Notebook instance using a **PyTorch kernel** to ensure a stable environment with pre-installed dependencies.
- Attached necessary IAM policies (`IAMFullAccess`, `AWSLambda_FullAccess`, `AmazonAPIGatewayAdministrator`) to the SageMaker execution role to grant permissions for resource creation.

### 2. Model Fine-Tuning
- The `Reviews.csv` dataset was uploaded to S3.
- A **DistilBERT** model (`distilbert-base-uncased`) was fine-tuned for binary sentiment classification using the `transformers` library.
- Fine-tuning was executed as a **SageMaker Training Job**, launched from the notebook. This approach uses dedicated, powerful instances for training without disrupting the notebook environment.
- The training script (`train.py`) and its dependencies (`requirements.txt`) were passed to the SageMaker PyTorch Estimator.

### 3. Model Deployment to SageMaker Endpoint
- The fine-tuned model artifact (`model.tar.gz`), saved by the training job in S3, was deployed to a **real-time SageMaker Endpoint**.
- An `inference.py` script was created to define the model loading and prediction logic for the endpoint.
- The deployment used a cost-effective `ml.t2.medium` instance.

### 4. Serverless API Deployment (Boto3)
- An AWS Lambda function and an API Gateway (HTTP API) were deployed programmatically from the notebook using **Boto3**.
- **Lambda Function**: Serves as a proxy that takes a JSON request, invokes the SageMaker endpoint, and returns the model's prediction. This decouples the client from the SageMaker infrastructure.
- **API Gateway**: Provides a public, serverless HTTP endpoint that triggers the Lambda function.

### 5. Testing
- The SageMaker endpoint was tested directly from the notebook using the SageMaker SDK.
- The final API Gateway endpoint was tested to confirm the end-to-end workflow.

### 6. (Optional) Cleanup
- The notebook includes cells with Boto3 commands to delete all created resources (API Gateway, Lambda function, SageMaker endpoint) to prevent ongoing costs.

---

## 🚀 How to Run

### Prerequisites
- An AWS account with SageMaker, S3, Lambda, API Gateway, and IAM permissions.
- A SageMaker Notebook instance with a **PyTorch kernel**.
- The SageMaker execution role must have the following AWS-managed policies attached: `AmazonSageMakerFullAccess`, `IAMFullAccess`, `AWSLambda_FullAccess`, `AmazonAPIGatewayAdministrator`.

### Run Instructions
1. Upload this folder as-is to a Sagemaker Notebook instance.
2. Download the dataset from `https://www.kaggle.com/datasets/snap/amazon-fine-food-reviews?resource=download`and upload `Reviews.csv` to the working directory.
    - I couldn't include this in GitHub because the filesize is *286MB* which exceeds GitHub's limit of *100MB*
3. Open `fine_tune.ipynb`.
4. Run the cells in order to:
   - Upload the dataset to S3.
   - Launch the SageMaker fine-tuning job.
   - Deploy the fine-tuned model to a SageMaker endpoint.
   - Deploy the Lambda function and API Gateway.
   - Test the final API endpoint.
5. (Optional) Run the cleanup cells at the end of the notebook to delete all AWS resources.

---

## 📊 Results
- A DistilBERT model was successfully fine-tuned to classify the sentiment of customer reviews.
    - Located at: `s3://sagemaker-us-east-1-059006397895/pytorch-training-2025-08-26-20-29-32-740/output/model.tar.gz` 
- The model is served by a scalable, real-time SageMaker endpoint.
    - Located at: `https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/pytorch-inference-2025-08-26-21-01-41-724/invocations`
- A serverless, public API provides an easy-to-use interface for getting sentiment predictions, demonstrating a production-ready architecture.
    - Located at: `https://30522nn89f.execute-api.us-east-1.amazonaws.com/`

---

## 🔑 Notes & Tips
- **Permissions**: The most common issues arise from IAM permissions. The script requires the SageMaker role to be able to create and manage Lambda and API Gateway resources, which is not default behavior.
- **Boto3 vs. Terraform**: While this project uses Boto3 for rapid, self-contained deployment from a notebook, using Terraform (as in Task 2) is the recommended best practice for managing production infrastructure.
- **Cleanup**: Always run the cleanup cells to avoid unexpected charges from lingering SageMaker endpoints, Lambda functions, and other resources.