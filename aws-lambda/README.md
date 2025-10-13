# AWS Rekognition Lambda Starter

This project provisions a serverless pipeline that detects image labels with Amazon Rekognition. Terraform creates the infrastructure (S3 bucket, Lambda function, IAM roles, and notifications) and the included Python utilities help you upload images and verify the end-to-end flow.

## Prerequisites
- Terraform ≥ 1.5
- AWS CLI with valid credentials and a default region
- [uv](https://github.com/astral-sh/uv) for Python dependency management
- Python 3.12 (declared in `.python-version`)

## Quick Start
```bash
uv sync
make e2e
```
`make e2e` runs the full lifecycle: deploys the Terraform stack, uploads a sample image, polls CloudWatch logs for Rekognition output, and then destroys the resources.

### Target Highlights
- `make deploy` – applies Terraform and writes `.tf_outputs.env` containing the generated bucket and Lambda names.
- `make upload` – uploads `test-image.jpg` (or `IMAGE=<path>` override) using `rekognition_client.py`.
- `make smoke-test` – polls CloudWatch logs until it finds the "Labels detected" entry.
- `make destroy` – destroys the stack and removes `.tf_outputs.env`.
- `make clean` – removes local artifacts (zip, cached outputs, Terraform state directories, etc.).

## Troubleshooting
- **Bucket not found:** Remove `.tf_outputs.env` (or run `make clean`) and redeploy. The file caches the last successful Terraform outputs and must contain real bucket/function names.
- **Smoke test timeout:** Tail the Lambda logs directly with `aws logs tail /aws/lambda/<function-name>` to inspect recent invocations and errors.
- **Stale resources:** If Terraform destroy fails because the bucket is not empty, verify that `force_destroy = true` remains set on the S3 bucket resource.

## Repository Layout
- `lambda_function.py` – Rekognition-enabled Lambda handler.
- `rekognition_client.py` – CLI helper for uploading test images.
- `terraform/` – Terraform root module plus `modules/lambda_function` for the Lambda + IAM resources.
- `Makefile` – automation entry points described above.
