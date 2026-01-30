"""
AWS Rekognition Client

This script uploads a file to an S3 bucket and uses AWS Rekognition to detect faces in the image.
"""

import os
import sys

import boto3
from botocore.exceptions import NoCredentialsError


def upload_to_s3(bucket_name: str, file_path: str) -> bool:
    """Uploads a file to an S3 bucket."""
    s3 = boto3.client("s3")
    try:
        file_name = os.path.basename(file_path)
        s3.upload_file(file_path, bucket_name, file_name)
        print(f"Upload Successful: '{file_path}' to '{bucket_name}'.")
        return True
    except FileNotFoundError:
        print(f"Error: The file was not found at '{file_path}'.")
        return False
    except NoCredentialsError:
        print("Error: AWS credentials not available.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return False


def main() -> None:
    """Main function to handle command-line arguments."""
    if len(sys.argv) != 3:
        print("Usage: python rekognition_client.py <bucket_name> <file_path>")
        sys.exit(1)

    bucket_name = sys.argv[1]
    file_path = sys.argv[2]
    upload_to_s3(bucket_name, file_path)


if __name__ == "__main__":
    main()
