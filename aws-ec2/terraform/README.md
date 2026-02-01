<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | ./modules/ec2_instance | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ./modules/security_group | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_cidr"></a> [allowed\_ssh\_cidr](#input\_allowed\_ssh\_cidr) | CIDR block allowed to access SSH (port 22). Use your IP with /32 suffix (e.g., '203.0.113.1/32'). Set to '0.0.0.0/0' only for testing. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The ID of the AMI to use for the EC2 instance. If not specified, the latest Amazon Linux 2 AMI will be used. | `string` | `null` | no |
| <a name="input_ec2_volume_size"></a> [ec2\_volume\_size](#input\_ec2\_volume\_size) | The size of the root EBS volume in GB for the EC2 instance. | `number` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name to suffix resource identifiers and tags (e.g., prod, staging, e2e-test). | `string` | `"prod"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The EC2 instance type to use. Choose based on your needs: t2/t3.micro for testing, t2/t3.small for development, t2/t3.medium or larger for production. Note that not all instance types are available in all regions. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy the resources in. | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | The CIDR block for the subnet. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID used for the EC2 instance |
| <a name="output_ami_name"></a> [ami\_name](#output\_ami\_name) | Name of the Amazon Linux 2 AMI (from data source lookup) |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | Public IP of the EC2 instance |
| <a name="output_private_key_file"></a> [private\_key\_file](#output\_private\_key\_file) | Path to the private key file for SSH access |
<!-- END_TF_DOCS -->