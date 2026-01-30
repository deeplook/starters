import json
import boto3
import urllib.parse


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

    except Exception as e:
        print(f"Error processing image: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error processing image", "error": str(e)}),
        }
