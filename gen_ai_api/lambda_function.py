import json
from transformers import pipeline

# Load the model. This will download the model the first time the Lambda is run.
# For production, you would package the model with your deployment.
summarizer = pipeline("summarization", model="t5-small")

def lambda_handler(event, context):
    """
    This function takes a text input and returns a summary.
    """
    try:
        # The input text will be passed in the 'body' of the API Gateway event
        body = json.loads(event.get("body", "{}"))
        input_text = body.get("text")

        if not input_text:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "No text provided for summarization."})
            }

        # Generate the summary
        summary = summarizer(input_text, max_length=100, min_length=30, do_sample=False)
        
        return {
            "statusCode": 200,
            "body": json.dumps(summary[0])
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "An error occurred during processing."})
        }