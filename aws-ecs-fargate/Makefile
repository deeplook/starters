## Usage: make [target] [ENV=dev]
## This Makefile mirrors the EC2/App Runner starters, adapted for ECS Fargate.

SHELL := /bin/bash
ENV ?= dev
export TF_VAR_environment := $(ENV)

# Derive values from terraform.tfvars when available
PROJECT_NAME := $(shell cd terraform && grep -E '^\s*project_name\s*=' terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
AWS_REGION   := $(shell cd terraform && grep -E '^\s*aws_region\s*=' terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
IMAGE_TAG    := $(shell cd terraform && grep -E '^\s*docker_image_tag\s*=' terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' "')

.PHONY: help
help:
	@echo "Targets:"
	@echo "  fmt          terraform fmt -recursive"
	@echo "  validate     terraform validate"
	@echo "  plan         terraform plan"
	@echo "  tf-docs      Generate Terraform docs (requires terraform-docs)"
	@echo "  setup        Initialize Terraform and bootstrap tfvars if missing"
	@echo "  infra        Apply Terraform to create/update infrastructure (incl. ECR) (ENV=$(ENV))"
	@echo "  build        Build and push Docker image to ECR (uses build-and-push.sh; ENV=$(ENV))"
	@echo "  deploy       Run infra then build (full deploy) (ENV=$(ENV))"
	@echo "  url          Print Load Balancer DNS name"
	@echo "  open         Open the app URL in browser"
	@echo "  smoke        Poll the app URL until HTTP 200"
	@echo "  destroy      terraform destroy -auto-approve (ENV=$(ENV))"
	@echo "  e2e          Run full end-to-end test"
	@echo "  clean        Remove local TF artifacts and generated docs"
	@echo ""
	@echo "Env vars:"
	@echo "  ENV=<name>   Terraform environment (default: dev)"

.PHONY: fmt
fmt:
	cd terraform && terraform fmt -recursive

.PHONY: validate
validate:
	cd terraform && terraform validate

.PHONY: plan
plan:
	cd terraform && terraform plan

.PHONY: tf-docs
tf-docs:
	@command -v terraform-docs >/dev/null 2>&1 || { \
	  echo "terraform-docs not found. Install it, e.g.:\n  brew install terraform-docs"; \
	  exit 1; \
	}
	@echo "Generating Terraform documentation..."
	@terraform-docs markdown --recursive --output-file doc.md ./terraform

.PHONY: setup
setup:
	@echo "--- Setting up Terraform ---"
	cd terraform && \
	  { [ -f ./terraform.tfvars ] || { echo "Creating terraform.tfvars from example..."; cp terraform.tfvars.example terraform.tfvars; }; } && \
	  terraform init

.PHONY: infra
infra:
	cd terraform && terraform apply -auto-approve

.PHONY: build
build:
	cd terraform && PROJECT_NAME="$(PROJECT_NAME)" AWS_REGION="$(AWS_REGION)" ENVIRONMENT="$(ENV)" IMAGE_TAG="$(IMAGE_TAG)" ./build-and-push.sh

.PHONY: deploy
deploy: infra build

.PHONY: url
url:
	cd terraform && URL=$$(terraform output -raw load_balancer_dns_name) && echo "http://$${URL}"

.PHONY: open
open:
	cd terraform && open http://$$(terraform output -raw load_balancer_dns_name)

.PHONY: smoke
smoke:
	@echo "--- Running HTTP smoke check ---"
	cd terraform && \
	  URL=$$(terraform output -raw load_balancer_dns_name) && \
	  echo "Target: http://$${URL}" && \
	  MAX_RETRIES=60; RETRY_INTERVAL=10; \
	  for i in $$(seq 1 $$MAX_RETRIES); do \
	    CODE=$$(curl --connect-timeout 5 -s -o /dev/null -w "%{http_code}" http://$${URL} || true); \
	    if [ "$$CODE" = "200" ]; then echo "✅ Service healthy (HTTP $$CODE)"; exit 0; fi; \
	    echo "Attempt $$i/$$MAX_RETRIES: not ready (HTTP $$CODE). Retrying in $$RETRY_INTERVALs..."; \
	    sleep $$RETRY_INTERVAL; \
	  done; \
	  echo "❌ Service did not become healthy in time."; exit 1

.PHONY: destroy
destroy:
	cd terraform && terraform destroy -auto-approve

.PHONY: e2e
e2e:
	./terraform/test_e2e.sh

.PHONY: clean
clean:
	@echo "Cleaning up project..."
	find . -type f -name 'doc.md' -delete
	rm -f terraform/tf_outputs.env
	rm -f terraform/terraform.tfstate terraform/terraform.tfstate.backup
	rm -rf terraform/.terraform
	# Keep root module's .terraform.lock.hcl but remove from child modules
	find terraform/modules -name .terraform.lock.hcl -delete
