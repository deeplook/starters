import json
import urllib.parse

import boto3
from botocore.exceptions import ClientError, EndpointConnectionError, NoCredentialsError


def lambda_handler(event, context):
    """
    Lambda function that uses Amazon Rekognition to detect labels in an image.
    """
    print("Lambda function started.")

    # Validate event structure
    if not event.get("Records") or len(event["Records"]) == 0:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid event: no Records found"}),
        }

    s3_event = event["Records"][0].get("s3")
    if not s3_event:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid event: no S3 event found"}),
        }

    bucket_name = s3_event.get("bucket", {}).get("name")
    object_key = s3_event.get("object", {}).get("key")

    if not bucket_name or not object_key:
        return {
            "statusCode": 400,
            "body": json.dumps(
                {"message": "Invalid event: missing bucket name or object key"}
            ),
        }

    object_key = urllib.parse.unquote_plus(object_key, encoding="utf-8")

    print(f"Processing object {object_key} from bucket {bucket_name}")

    rekognition = boto3.client("rekognition")

    try:
        response = rekognition.detect_labels(
            Image={"S3Object": {"Bucket": bucket_name, "Name": object_key}},
            MaxLabels=10,
            MinConfidence=75,
        )

        labels = response["Labels"]
        print(f"Labels detected for {object_key}:")
        for label in labels:
            print(f"- {label['Name']}: {label['Confidence']:.2f}%")

        return {
            "statusCode": 200,
            "body": json.dumps(
                {"message": "Label detection successful", "labels": labels}
            ),
        }

    except NoCredentialsError as e:
        print(f"AWS credentials error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "AWS credentials not available"}),
        }

    except EndpointConnectionError as e:
        print(f"Connection error: {e}")
        return {
            "statusCode": 503,
            "body": json.dumps({"message": "Unable to connect to AWS service"}),
        }

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_message = e.response["Error"]["Message"]
        print(f"AWS API error ({error_code}): {error_message}")

        # Map specific AWS errors to appropriate HTTP status codes
        if error_code == "AccessDeniedException":
            status_code = 403
        elif error_code == "InvalidS3ObjectException":
            status_code = 400
        elif error_code == "ThrottlingException":
            status_code = 429
        else:
            status_code = 500

        return {
            "statusCode": status_code,
            "body": json.dumps({"message": error_message}),
        }

    except Exception as e:
        # Catch-all for truly unexpected errors (should be rare)
        print(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Internal server error"}),
        }
