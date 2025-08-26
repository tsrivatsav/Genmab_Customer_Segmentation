from transformers import pipeline, DistilBertTokenizer, DistilBertForSequenceClassification
import json

def model_fn(model_dir):
    """Loads the fine-tuned model and tokenizer from the disk."""
    tokenizer = DistilBertTokenizer.from_pretrained(model_dir)
    model = DistilBertForSequenceClassification.from_pretrained(model_dir)
    return pipeline("text-classification", model=model, tokenizer=tokenizer)

def input_fn(request_body, request_content_type):
    """Parses the input JSON request."""
    if request_content_type == 'application/json':
        return json.loads(request_body)
    raise ValueError(f"Unsupported content type: {request_content_type}")

def predict_fn(input_data, model):
    """Runs prediction on the parsed input."""
    text = input_data.pop("text", "")
    return model(text)

def output_fn(prediction, content_type):
    """Formats the prediction output into a JSON string."""
    return json.dumps(prediction)