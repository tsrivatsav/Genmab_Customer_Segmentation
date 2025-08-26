# Customer Segmentation with Scikit-learn and AWS SageMaker

This folder implements **Task 1** of the *R13306 Senior ML Engineer Technical Assessment*:  
> Build and deploy a simple AI model for a customer segmentation use case using AWS SageMaker.

We use **scikit-learn** instead of SageMaker’s built-in KMeans to demonstrate flexibility in training locally, packaging the model, and deploying it to SageMaker for inference.

---

## 📂 Project Structure
```
├── customer_segmentation_data.csv   # Input dataset
├── customer_segmentation.ipynb      # Full notebook with training + deployment
├── inference.py                     # Inference script for SageMaker endpoint
├── kmeans_model.pkl                 # Trained model artifact (generated)
└── README.md                        # Documentation
```

---

## ⚙️ Steps Implemented

### 1. Import Dependencies
- Imported pandas and sklearn libraries within Sagemaker notebook

### 2. Data Loading & Exploration
- Loaded `customer_segmentation_data.csv` genmab-assessment s3 bucket

### 3a. Preprocessing
- Dropped Customer ID column because it wasn't useful
- Numerically encoded gender column
- Standardized features using `StandardScaler`.
- Prepared data for clustering.

### 3b. Model Training
- Trained **KMeans clustering** on scaled features.
- Selected optimal number of clusters using: 
  - **Silhouette score**  

### 4. Model Saving + Upload to S3
- Saved trained `KMeans` model, scaler, and feature names as `kmeans_model.pkl` using `pickle`:
  - We store a tuple: `(kmeans_model, scaler, feature_names)`.
- Uploaded the model artifact to s3://genmab-assessment/customer-segmentation/model.tar.gz

### 5. Inference Script
- `inference.py` defines the 4 SageMaker hooks:
  - `model_fn`: load trained model, scaler, feature names  
  - `input_fn`: parse JSON input (expects `{"instances": [[...],[...]]}`)  
  - `predict_fn`: scale inputs, predict clusters  
  - `output_fn`: return JSON response  

### 6. Deployment
- Used **`SKLearnModel`** from SageMaker SDK to deploy the model:
- endpoint_name = "customer-segmentation-endpoint"
- instance_type = "ml.m5.large"

### 7. Testing
- Sent sample input to the deployed endpoint and received cluster predictions.

### 8. Cleanup (Optional)
- Delete endpoint to prevent costs:

## 🚀 Deployment Guide

### Prerequisites
- AWS account with SageMaker, S3, and IAM permissions.
- An existing SageMaker execution role.
- Python environment with:
  ```bash
  pip install sagemaker scikit-learn boto3
  ```

### Run Instructions
1. Place this entire folder as-is within Sagemaker notebook instance. Upload `customer_segmentation_data.csv` to S3 and adjust path in notebook accordingly. You might need to adjust IAM permissions for your AWS role to access S3 and Sagemaker.
2. Open `customer_segmentation.ipynb` in Jupyter Notebook python + sklearn instance.
3. Run all cells to:
   - Train the model with scikit-learn.
   - Upload artifacts to S3.
   - Deploy the model to a SageMaker endpoint.
4. Use the sample prediction call to test the endpoint.
5. Optionally run the cleanup step (`predictor.delete_endpoint()`) when done.

---

## 📊 Results
- The dataset is segmented into **10 customer groups** (selected via silhouette score).
- Endpoint serves **real-time segmentation predictions** for new customer records as JSON.
- Endpoint url: https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/customer-segmentation-endpoint/invocations
- *Note that the code creates the above url but as part of step 2 I changed it to the following:*
  - https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/genmab-takehome-segmentation-endpoint/invocations
---

## 🔑 Notes & Tips
- **Framework version**: If `framework_version="1.2-1"` is not available in your region, change to a supported version (e.g., `"1.0-1"` or a newer available tag).
- **Execution Role**: In SageMaker Studio, `sagemaker.get_execution_role()` works automatically. Elsewhere, set your role ARN explicitly.
- **Input ordering**: The endpoint expects features in the same order used during training (saved as `feature_names`). Sending arrays preserves order. If sending as dicts, transform them to arrays in that order before calling `predict()`.