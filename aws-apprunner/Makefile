tf-docs:
	@echo "Generating Terraform documentation..."
	terraform-docs markdown --recursive --output-file doc.md ./terraform

clean:
	@echo "Cleaning up project..."
	find . -type f -name 'doc.md' -delete
	rm -f terraform/tf_outputs.env
	rm -f terraform/terraform.tfstate terraform/terraform.tfstate.backup terraform/.terraform.lock.hcl
	rm -rf terraform/.terraform

test-e2e:
	@echo "Running end-to-end tests..."
	@./terraform/test_e2e.sh

.PHONY: destroy
destroy:
	@echo "Destroying App Runner PROD infrastructure..."
	# This destroys the default 'prod' environment.
	# The ephemeral 'e2e-test' environment is destroyed automatically by the GitHub workflow.
	cd terraform && terraform destroy -auto-approve
