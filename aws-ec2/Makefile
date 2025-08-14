## Usage: make [target] [ENV=prod]
## This Makefile mirrors the App Runner starter where sensible, adapted for EC2.

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
	@echo "  setup        Initialize Terraform and bootstrap tfvars if missing"
	@echo "  deploy       terraform apply -auto-approve (ENV=$(ENV))"
	@echo "  ip           Print EC2 instance public IP"
	@echo "  url          Print EC2 web URL (http://<ip>)"
	@echo "  open         Open EC2 web URL in browser"
	@echo "  smoke        Run HTTP and SSH smoke checks (composite)"
	@echo "  smoke-ssh    Run SSH smoke check against EC2 instance"
	@echo "  smoke-http   Run HTTP smoke check against EC2 instance"
	@echo "  destroy      terraform destroy -auto-approve (ENV=$(ENV))"
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
	@terraform-docs markdown --recursive --output-file doc.md ./terraform

.PHONY: setup
setup:
	@echo "--- Setting up Terraform ---"
	cd terraform && \
	  { [ -f ./terraform.tfvars ] || { echo "Creating terraform.tfvars from example..."; cp terraform.tfvars.example terraform.tfvars; }; } && \
	  terraform init

.PHONY: deploy
deploy:
	cd terraform && terraform apply -auto-approve

.PHONY: ip
ip:
	cd terraform && terraform output -raw instance_public_ip

.PHONY: url
url:
	cd terraform && IP=$$(terraform output -raw instance_public_ip) && echo "http://$${IP}"

.PHONY: open
open:
	cd terraform && open http://$$(terraform output -raw instance_public_ip)

.PHONY: smoke
smoke: smoke-http smoke-ssh

.PHONY: smoke-ssh
smoke-ssh:
	@echo "--- Running SSH smoke check ---"
	cd terraform && \
	  IP=$$(terraform output -raw instance_public_ip) && \
	  KEY=$$(terraform output -raw private_key_file) && \
	  SSH_OUTPUT=$$(ssh -i $$KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$$IP uname -a || true); \
	  if echo "$$SSH_OUTPUT" | grep -q Linux; then \
	    echo "✅ SSH connection successful."; \
	    echo "Kernel: $$SSH_OUTPUT"; \
	  else \
	    echo "❌ SSH connection failed."; \
	    exit 1; \
	  fi

.PHONY: smoke-http
smoke-http:
	@echo "--- Running HTTP smoke check ---"
	cd terraform && \
	  IP=$$(terraform output -raw instance_public_ip) && \
	  echo "Target: http://$${IP}" && \
	  MAX_RETRIES=30; RETRY_INTERVAL=5; \
	  for i in $$(seq 1 $$MAX_RETRIES); do \
	    CODE=$$(curl --connect-timeout 5 -s -o /dev/null -w "%{http_code}" http://$${IP} || true); \
	    if [ "$$CODE" = "200" ]; then echo "✅ HTTP healthy (HTTP $$CODE)"; exit 0; fi; \
	    echo "Attempt $$i/$$MAX_RETRIES: not ready (HTTP $$CODE). Retrying in $$RETRY_INTERVALs..."; \
	    sleep $$RETRY_INTERVAL; \
	  done; \
	  echo "❌ Web server did not become ready in time."; exit 1

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
