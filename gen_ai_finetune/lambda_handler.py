
import os
import boto3
import json

ENDPOINT_NAME = 'pytorch-inference-2025-08-26-21-01-41-724'
sagemaker_runtime = boto3.client('sagemaker-runtime')

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        response = sagemaker_runtime.invoke_endpoint(
            EndpointName=ENDPOINT_NAME,
            ContentType='application/json',
            Body=json.dumps(body)
        )
        result = response['Body'].read().decode('utf-8')
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': result
        }
    except Exception as e:
        print(e)
        return {'statusCode': 500, 'body': json.dumps('Error invoking endpoint.')}
