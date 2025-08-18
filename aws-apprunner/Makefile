# Usage: make [target] [ENV=prod]
# ENV controls TF var "environment" via TF_VAR_environment

SHELL := /bin/bash
ENV ?= prod
export TF_VAR_environment := $(ENV)

.PHONY: help
help:
	@echo "Targets:"
	@echo "  fmt          terraform fmt -recursive"
	@echo "  validate     terraform validate"
	@echo "  plan         terraform plan"
	@echo "  tf-docs      Generate Terraform docs (requires terraform-docs)"
	@echo "  setup        Init Terraform and create ECR"
	@echo "  deploy       Build image, push to ECR, apply App Runner"
	@echo "  url          Print App Runner service URL"
	@echo "  open         Open the service in browser"
	@echo "  smoke        Run smoke tests against the service"
	@echo "  destroy      Tear down all resources"
	@echo "  e2e          Full end-to-end test"
	@echo "  clean        Remove local TF artifacts"
	@echo ""
	@echo "Env vars:"
	@echo "  ENV=<name>   Terraform environment (default: prod)"

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
	cd terraform && terraform-docs markdown --recursive --lockfile=false --output-file README.md --output-mode replace .

.PHONY: setup
setup:
	cd terraform && ./setup.sh

.PHONY: deploy
deploy:
	cd terraform && ./push_image.sh

.PHONY: url
url:
	cd terraform && echo http://$$(terraform output -raw app_service_url)

.PHONY: open
open:
	cd terraform && open https://$$(terraform output -raw app_service_url)

.PHONY: smoke
smoke:
	cd terraform && ./run_smoke_tests.sh "$$(terraform output -raw app_service_url)"

.PHONY: destroy
destroy:
	cd terraform && ./teardown.sh

.PHONY: e2e
e2e:
	./terraform/test_e2e.sh

.PHONY: clean
clean:
	@echo "Cleaning up project..."
	rm -f terraform/tf_outputs.env
	rm -f terraform/terraform.tfstate terraform/terraform.tfstate.backup
	rm -rf terraform/.terraform
	# Keep root module's .terraform.lock.hcl but remove from child modules
	find terraform/modules -name .terraform.lock.hcl -delete
