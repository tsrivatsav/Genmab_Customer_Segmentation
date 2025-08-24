
import pickle
import os
import json
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.cluster import KMeans

def model_fn(model_dir):
    """Load model from artifact"""
    with open(os.path.join(model_dir, "kmeans_model.pkl"), "rb") as f:
        model, scaler = pickle.load(f)
    return model, scaler

def input_fn(request_body, request_content_type):
    """Deserialize request"""
    if request_content_type == "application/json":
        data = json.loads(request_body)
        return np.array(data["instances"])
    else:
        raise ValueError("Unsupported content type: " + request_content_type)

def predict_fn(input_data, model_and_scaler):
    """Run prediction"""
    model, scaler = model_and_scaler
    scaled = scaler.transform(input_data)
    preds = model.predict(scaled)
    return preds.tolist()

def output_fn(prediction, accept):
    """Serialize output"""
    if accept == "application/json":
        return json.dumps({"predictions": prediction}), accept
    else:
        raise ValueError("Unsupported accept type: " + accept)
