# Terraform Documentation



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where resources will be created. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A unique name for the project, used for tagging and naming resources. | `string` | n/a | yes |
| <a name="input_autoscale_cpu_target"></a> [autoscale\_cpu\_target](#input\_autoscale\_cpu\_target) | The target average CPU utilization (in percent) for autoscaling. | `number` | `75` | no |
| <a name="input_autoscale_max_tasks"></a> [autoscale\_max\_tasks](#input\_autoscale\_max\_tasks) | The maximum number of tasks for autoscaling. | `number` | `3` | no |
| <a name="input_autoscale_min_tasks"></a> [autoscale\_min\_tasks](#input\_autoscale\_min\_tasks) | The minimum number of tasks for autoscaling. | `number` | `1` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of CPU units to reserve for the container. | `number` | `256` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount of memory (in MiB) to reserve for the container. | `number` | `512` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container listens on. | `number` | `5001` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | The tag of the Docker image to deploy. | `string` | `"latest"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment (e.g., 'dev', 'staging', 'prod'). | `string` | `"dev"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to deploy into. If not provided, the default VPC will be used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | The URL of the ECR repository |
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | The DNS name of the load balancer |
