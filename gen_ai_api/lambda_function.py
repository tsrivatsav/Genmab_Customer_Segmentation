import os
import boto3
import json

# Get the SageMaker endpoint name from an environment variable
ENDPOINT_NAME = os.environ['SAGEMAKER_ENDPOINT_NAME']

# Create a boto3 client for the SageMaker runtime
sagemaker_runtime = boto3.client('sagemaker-runtime')

def lambda_handler(event, context):
    try:
        # Get the input text from the API Gateway event
        body = json.loads(event.get("body", "{}"))
        input_text = body.get("text")

        if not input_text:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No text provided.'})
            }

        # The payload must be a JSON string, then encoded to bytes
        payload = json.dumps({'text': input_text})

        # Invoke the SageMaker endpoint
        response = sagemaker_runtime.invoke_endpoint(
            EndpointName=ENDPOINT_NAME,
            ContentType='application/json',
            Body=payload
        )

        # The response body from SageMaker is a streaming object, so we read and decode it
        result = response['Body'].read().decode('utf-8')

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': result # The result from SageMaker is already a JSON string
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'An internal server error occurred.'})
        }