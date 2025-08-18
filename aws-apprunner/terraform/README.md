<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apprunner"></a> [apprunner](#module\_apprunner) | ./modules/apprunner | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/ecr | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to merge with common tags. | `map(string)` | `{}` | no |
| <a name="input_app_autoscale_config_name"></a> [app\_autoscale\_config\_name](#input\_app\_autoscale\_config\_name) | The name of the App Runner auto-scaling configuration. | `string` | n/a | yes |
| <a name="input_app_environment_variables"></a> [app\_environment\_variables](#input\_app\_environment\_variables) | Environment variables for the App Runner service. | `map(string)` | n/a | yes |
| <a name="input_app_health_check_interval"></a> [app\_health\_check\_interval](#input\_app\_health\_check\_interval) | The health check interval in seconds. | `number` | `5` | no |
| <a name="input_app_health_check_path"></a> [app\_health\_check\_path](#input\_app\_health\_check\_path) | The health check path. | `string` | `"/"` | no |
| <a name="input_app_health_check_timeout"></a> [app\_health\_check\_timeout](#input\_app\_health\_check\_timeout) | The health check timeout in seconds. | `number` | `2` | no |
| <a name="input_app_healthy_threshold"></a> [app\_healthy\_threshold](#input\_app\_healthy\_threshold) | The number of consecutive successful health checks before marking as healthy. | `number` | `2` | no |
| <a name="input_app_image_identifier_override"></a> [app\_image\_identifier\_override](#input\_app\_image\_identifier\_override) | Optional override for the App Runner service image identifier. | `string` | `null` | no |
| <a name="input_app_instance_cpu"></a> [app\_instance\_cpu](#input\_app\_instance\_cpu) | The CPU units for the App Runner instance (256, 512, 1024, 2048, or 4096). | `number` | `1024` | no |
| <a name="input_app_instance_memory"></a> [app\_instance\_memory](#input\_app\_instance\_memory) | The memory in MB for the App Runner instance (512, 1024, 2048, 3072, or 4096). | `number` | `2048` | no |
| <a name="input_app_max_concurrency"></a> [app\_max\_concurrency](#input\_app\_max\_concurrency) | The maximum number of concurrent requests per instance. | `number` | `100` | no |
| <a name="input_app_max_size"></a> [app\_max\_size](#input\_app\_max\_size) | The maximum number of instances for the App Runner service. | `number` | `10` | no |
| <a name="input_app_min_size"></a> [app\_min\_size](#input\_app\_min\_size) | The minimum number of instances for the App Runner service. | `number` | `1` | no |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | The port the application listens on. | `number` | `3000` | no |
| <a name="input_app_service_name"></a> [app\_service\_name](#input\_app\_service\_name) | The name of the App Runner service. | `string` | n/a | yes |
| <a name="input_app_unhealthy_threshold"></a> [app\_unhealthy\_threshold](#input\_app\_unhealthy\_threshold) | The number of consecutive failed health checks before marking as unhealthy. | `number` | `5` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the resources to. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_create_apprunner_service"></a> [create\_apprunner\_service](#input\_create\_apprunner\_service) | Whether to create the App Runner service. | `bool` | `true` | no |
| <a name="input_docker_build_platform"></a> [docker\_build\_platform](#input\_docker\_build\_platform) | The target platform for the Docker build (e.g., 'linux/amd64'). | `string` | n/a | yes |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | The name of the ECR repository. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name (e.g., 'prod', 'staging', 'dev'). | `string` | `"prod"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | The tag of the Docker image in ECR (e.g., 'latest'). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_arn"></a> [app\_service\_arn](#output\_app\_service\_arn) | The ARN of the App Runner service |
| <a name="output_app_service_name"></a> [app\_service\_name](#output\_app\_service\_name) | The name of the App Runner service |
| <a name="output_app_service_url"></a> [app\_service\_url](#output\_app\_service\_url) | The URL of the App Runner service |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the ECR repository |
<!-- END_TF_DOCS -->
