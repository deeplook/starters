tf-docs:
	terraform-docs markdown --recursive --output-file doc.md ./terraform

clean:
	find . -type f -name 'doc.md' -delete
	rm -f terraform/tf_outputs.env
	rm -f terraform/terraform.tfstate terraform/terraform.tfstate.backup terraform/.terraform.lock.hcl
	rm -rf terraform/.terraform
