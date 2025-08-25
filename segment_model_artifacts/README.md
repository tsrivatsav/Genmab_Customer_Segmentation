# Customer Segmentation with Scikit-learn and AWS SageMaker

This project implements **Task 1** of the *R13306 Senior ML Engineer Technical Assessment*:  
> Build and deploy a simple AI model for a customer segmentation use case using AWS SageMaker.

We use **scikit-learn** instead of SageMaker’s built-in KMeans to demonstrate flexibility in training locally, packaging the model, and deploying it to SageMaker for inference.

---

## 📂 Project Structure
```
├── customer_segmentation_data.csv   # Input dataset
├── notebook.ipynb                   # Full notebook with training + deployment
├── inference.py                     # Inference script for SageMaker endpoint
├── kmeans_model.pkl                 # Trained model artifact (generated)
└── README.md                        # Documentation
```

---

## ⚙️ Steps Implemented

### 1. Data Loading & Exploration
- Loaded `customer_segmentation_data.csv`.
- Selected only numeric features.
- Filled missing values with column means.

### 2. Preprocessing
- Standardized features using `StandardScaler`.
- Prepared data for clustering.

### 3. Model Training
- Trained **KMeans clustering** on scaled features.
- Selected optimal number of clusters using:
  - **Elbow method (Inertia)**  
  - **Silhouette score**  

### 4. Model Saving
- Saved trained `KMeans` model, scaler, and feature names as `kmeans_model.pkl` using `pickle`:
  - We store a tuple: `(kmeans_model, scaler, feature_names)`.

### 5. Upload to S3
- Uploaded the model artifact to an S3 bucket:
  ```python
  model_artifact = session.upload_data("kmeans_model.pkl", bucket=bucket, key_prefix="customer-segmentation")
  ```

### 6. Inference Script
- `inference.py` defines the 4 SageMaker hooks:
  - `model_fn`: load trained model, scaler, feature names  
  - `input_fn`: parse JSON input (expects `{"instances": [[...],[...]]}`)  
  - `predict_fn`: scale inputs, predict clusters  
  - `output_fn`: return JSON response  

### 7. Deployment
- Use **`SKLearnModel`** from SageMaker SDK to deploy the model:
  ```python
  from sagemaker.sklearn.model import SKLearnModel

  sklearn_model = SKLearnModel(
      model_data=model_artifact,
      role=role,
      entry_point="inference.py",
      framework_version="1.2-1",
      py_version="py3"
  )

  predictor = sklearn_model.deploy(
      instance_type="ml.m5.large",
      initial_instance_count=1,
      endpoint_name="customer-segmentation-endpoint"
  )
  ```

### 8. Testing
- Send sample input to the deployed endpoint:
  ```python
  response = predictor.predict({"instances": sample_data.tolist()})
  print(response)
  ```

### 9. Cleanup
- Delete endpoint to prevent costs:
  ```python
  predictor.delete_endpoint()
  ```

---

## 🚀 Deployment Guide

### Prerequisites
- AWS account with SageMaker, S3, and IAM permissions.
- An existing SageMaker execution role.
- Python environment with:
  ```bash
  pip install sagemaker scikit-learn boto3
  ```

### Run Instructions
1. Place `customer_segmentation_data.csv` next to the notebook or adjust the path.
2. Open `notebook.ipynb` in **SageMaker Studio** or Jupyter with AWS credentials.
3. Run all cells to:
   - Train the model with scikit-learn.
   - Upload artifacts to S3.
   - Deploy the model to a SageMaker endpoint.
4. Use the sample prediction call to test the endpoint.
5. **Important**: Run the cleanup step (`predictor.delete_endpoint()`) when done.

---

## 📊 Results
- The dataset is segmented into **K customer groups** (selected via silhouette score).
- Endpoint serves **real-time predictions** for new customer records as JSON.

---

## 🔑 Notes & Tips
- **Framework version**: If `framework_version="1.2-1"` is not available in your region, change to a supported version (e.g., `"1.0-1"` or a newer available tag).
- **Execution Role**: In SageMaker Studio, `sagemaker.get_execution_role()` works automatically. Elsewhere, set your role ARN explicitly.
- **Input ordering**: The endpoint expects features in the same order used during training (saved as `feature_names`). Sending arrays preserves order. If sending as dicts, transform them to arrays in that order before calling `predict()`.

---

## 🧹 Cleanup Reminder
Always delete endpoints after testing:
```python
predictor.delete_endpoint()
```