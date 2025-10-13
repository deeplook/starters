## Usage: make [target]

SHELL := /bin/bash
IMAGE ?= test-image.jpg

.PHONY: help
help:
	@echo "Targets:"
	@echo "  install      Install Python dependencies with uv"
	@echo "  fmt          Format Terraform code"
	@echo "  validate     Validate Terraform configuration"
	@echo "  plan         Create a Terraform execution plan"
	@echo "  setup        Initialize Terraform"
	@echo "  deploy       Apply the Terraform configuration"
	@echo "  destroy      Destroy the Terraform-managed infrastructure"
	@echo "  upload       Upload a test image to the S3 bucket (IMAGE=path/to/file.jpg)"
	@echo "  logs         Tail the logs for the Lambda function"
	@echo "  smoke-test   Check if the Lambda function is working correctly"
	@echo "  e2e          Run a full end-to-end test (deploy, upload, test, destroy)"
	@echo "  clean        Remove local build artifacts and caches"

.PHONY: install
install:
	uv sync

.PHONY: fmt

fmt:

	cd terraform && terraform fmt -recursive



.PHONY: validate

validate:

	cd terraform && terraform validate



.PHONY: plan

plan:

	cd terraform && terraform plan



.PHONY: setup

setup:

	cd terraform && terraform init



deploy: setup
	cd terraform && terraform apply -auto-approve
	@echo "export S3_BUCKET=$$(cd terraform && terraform output -raw s3_bucket_name)" > .tf_outputs.env
	@echo "export LAMBDA_NAME=$$(cd terraform && terraform output -raw lambda_function_name)" >> .tf_outputs.env

.PHONY: destroy
destroy:
	cd terraform && terraform destroy -auto-approve
	rm -f .tf_outputs.env

.PHONY: upload
upload:
	@if [ ! -f .tf_outputs.env ]; then \
		echo "Outputs file not found. Please run 'make deploy' first."; \
		exit 1; \
	fi
	@. .tf_outputs.env && \
	( \
		if [ ! -f "$(IMAGE)" ]; then \
			echo "Test image '$(IMAGE)' not found. Downloading..."; \
			wget -q -O $(IMAGE) https://www.booklistqueen.com/wp-content/uploads/books-to-read-in-2023-twitter.jpg; \
		fi; \
		echo "Uploading $(IMAGE) to bucket $$S3_BUCKET..."; \
		uv run rekognition_client.py $$S3_BUCKET $(IMAGE); \
	)

.PHONY: logs
logs:
	@if [ ! -f .tf_outputs.env ]; then \
		echo "Outputs file not found. Please run 'make deploy' first."; \
		exit 1; \
	fi
	@. .tf_outputs.env && \
	aws logs tail "/aws/lambda/$$LAMBDA_NAME" --follow

.PHONY: smoke-test
smoke-test:
	@echo "--- Running smoke test ---"
	@if [ ! -f .tf_outputs.env ]; then \
		echo "Outputs file not found. Please run 'make deploy' first."; \
		exit 1; \
	fi
	@. .tf_outputs.env && \
	( \
		LOG_GROUP="/aws/lambda/$$LAMBDA_NAME"; \
		echo "Checking logs in log group: $$LOG_GROUP"; \
		MAX_RETRIES=20; RETRY_INTERVAL=10; \
		for i in $$(seq 1 $$MAX_RETRIES); do \
		  echo "Attempt $$i/$$MAX_RETRIES: Checking logs..."; \
		  LOG_STREAM=$$(aws logs describe-log-streams --log-group-name "$$LOG_GROUP" --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text 2>/dev/null || echo "None"); \
		  if [ "$$LOG_STREAM" != "None" ]; then \
		    LOG_OUTPUT=$$(aws logs get-log-events --log-group-name "$$LOG_GROUP" --log-stream-name "$$LOG_STREAM" --query 'events[*].message' --output text); \
		    if echo "$$LOG_OUTPUT" | grep -q "Labels detected"; then \
		      echo "✅ Verification successful: Found 'Labels detected' in logs."; \
		      echo "$$LOG_OUTPUT"; \
		      exit 0; \
		    fi; \
		  fi; \
		  echo "Verification not successful yet. Retrying in $$RETRY_INTERVAL seconds..."; \
		  sleep $$RETRY_INTERVAL; \
		done; \
		echo "❌ Verification failed: Did not find expected output in CloudWatch logs."; exit 1; \
	)

.PHONY: e2e
e2e:
	make deploy
	make upload
	make smoke-test
	make destroy

.PHONY: clean
clean:
	rm -f lambda_function.zip
	rm -f test-image.jpg
	rm -f .tf_outputs.env
	rm -rf terraform/.terraform*
	rm -rf __pycache__
	rm -rf .ruff_cache
