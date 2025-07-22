## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.cpu_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.app_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscale_cpu_target"></a> [autoscale\_cpu\_target](#input\_autoscale\_cpu\_target) | The target average CPU utilization (in percent) for autoscaling. | `number` | `75` | no |
| <a name="input_autoscale_max_tasks"></a> [autoscale\_max\_tasks](#input\_autoscale\_max\_tasks) | The maximum number of tasks for autoscaling. | `number` | `3` | no |
| <a name="input_autoscale_min_tasks"></a> [autoscale\_min\_tasks](#input\_autoscale\_min\_tasks) | The minimum number of tasks for autoscaling. | `number` | `1` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in. | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The CPU units to allocate to the container. | `number` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The memory (in MiB) to allocate to the container. | `number` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container listens on. | `number` | n/a | yes |
| <a name="input_desired_task_count"></a> [desired\_task\_count](#input\_desired\_task\_count) | The desired number of tasks to run. | `number` | n/a | yes |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | The tag of the Docker image to deploy. | `string` | n/a | yes |
| <a name="input_docker_image_url"></a> [docker\_image\_url](#input\_docker\_image\_url) | The URL of the Docker image to deploy. | `string` | n/a | yes |
| <a name="input_ecs_tasks_sg_id"></a> [ecs\_tasks\_sg\_id](#input\_ecs\_tasks\_sg\_id) | The ID of the ECS tasks' security group. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment (e.g., 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_lb_sg_id"></a> [lb\_sg\_id](#input\_lb\_sg\_id) | The ID of the load balancer's security group. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project. | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | The IDs of the public subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources are deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | The DNS name of the load balancer |
