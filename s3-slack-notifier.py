import json
import urllib3
import boto3
from urllib.parse import unquote_plus

http = urllib3.PoolManager()

def lambda_handler(event, context):
    try:
        # Initialize Secrets Manager client
        secrets_client = boto3.client('secretsmanager')
        secret_response = secrets_client.get_secret_value(SecretId='slack-webhook-secret')
        secret = json.loads(secret_response['SecretString'])
        SLACK_WEBHOOK_URL = secret['url']

        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = unquote_plus(record['s3']['object']['key'])
            size = record['s3']['object']['size']
            
            # Craft Slack payload
            payload = {
                'text': f'{key} uploaded',
                'attachments': [{
                    'color': 'good',
                    'fields': [
                        {'title': 'Bucket', 'value': bucket, 'short': True},
                        {'title': 'File', 'value': key, 'short': True},
                        {'title': 'Size', 'value': f'{size} bytes', 'short': True},
                        {'title': 'Timestamp', 'value': record['eventTime'], 'short': True}
                    ]
                }]
            }
            
            # Post to Slack
            encoded_payload = json.dumps(payload).encode('utf-8')
            response = http.request('POST', SLACK_WEBHOOK_URL, body=encoded_payload)
            
            if response.status != 200:
                print(f"Slack post failed: {response.status}")
                raise Exception("Failed to send Slack message")
        
        return {'statusCode': 200, 'body': json.dumps('Message sent!')}
    except Exception as e:
        print(f"Error: {str(e)}")
        raise