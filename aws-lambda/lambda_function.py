import json
import boto3
import urllib.parse


def lambda_handler(event, context):
    """
    Lambda function that uses Amazon Rekognition to detect labels in an image.
    """
    print("Lambda function started.")

    # Get the bucket and key from the S3 event
    s3_event = event["Records"][0]["s3"]
    bucket_name = s3_event["bucket"]["name"]
    object_key = urllib.parse.unquote_plus(s3_event["object"]["key"], encoding="utf-8")

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
