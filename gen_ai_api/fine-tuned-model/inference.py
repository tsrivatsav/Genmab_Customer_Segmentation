import json
from transformers import T5Tokenizer, T5ForConditionalGeneration, pipeline

def model_fn(model_dir):
    """
    Loads the fine-tuned model from the local directory.
    """
    tokenizer = T5Tokenizer.from_pretrained(model_dir)
    model = T5ForConditionalGeneration.from_pretrained(model_dir)
    return pipeline("summarization", model=model, tokenizer=tokenizer)

def predict_fn(input_data, model):
    """
    Generates a summary for the input text.
    """
    text = input_data.pop("text", "")
    return model(text, max_length=100, min_length=30, do_sample=False)

def input_fn(request_body, request_content_type):
    """
    Deserializes the request body.
    """
    if request_content_type == "application/json":
        return json.loads(request_body)
    raise ValueError(f"Unsupported content type: {request_content_type}")

def output_fn(prediction, content_type):
    """
    Serializes the prediction into a JSON response.
    """
    if content_type == "application/json":
        return json.dumps(prediction)
    raise ValueError(f"Unsupported content type: {content_type}")