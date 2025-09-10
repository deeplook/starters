<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_apprunner_auto_scaling_configuration_version.app_autoscale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_auto_scaling_configuration_version) | resource |
| [aws_apprunner_service.app_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service) | resource |
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_role.apprunner_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.apprunner_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_autoscale_config_name"></a> [app\_autoscale\_config\_name](#input\_app\_autoscale\_config\_name) | The name of the App Runner auto-scaling configuration. | `string` | `"app-autoscale-config"` | no |
| <a name="input_app_environment_variables"></a> [app\_environment\_variables](#input\_app\_environment\_variables) | Environment variables for the App Runner service. | `map(string)` | <pre>{<br/>  "NODE_ENV": "production"<br/>}</pre> | no |
| <a name="input_app_health_check_interval"></a> [app\_health\_check\_interval](#input\_app\_health\_check\_interval) | The health check interval in seconds. | `number` | `5` | no |
| <a name="input_app_health_check_path"></a> [app\_health\_check\_path](#input\_app\_health\_check\_path) | The URL path for health checks. App Runner will send periodic HTTP GET requests to this path to monitor the application's health. Common values: '/' for a basic check, '/health' or '/status' for dedicated endpoints. | `string` | `"/"` | no |
| <a name="input_app_health_check_timeout"></a> [app\_health\_check\_timeout](#input\_app\_health\_check\_timeout) | The health check timeout in seconds. | `number` | `2` | no |
| <a name="input_app_healthy_threshold"></a> [app\_healthy\_threshold](#input\_app\_healthy\_threshold) | The number of consecutive successful health checks before marking as healthy. | `number` | `2` | no |
| <a name="input_app_instance_cpu"></a> [app\_instance\_cpu](#input\_app\_instance\_cpu) | The CPU units for the App Runner instance (256, 512, 1024, 2048, or 4096). | `number` | `1024` | no |
| <a name="input_app_instance_memory"></a> [app\_instance\_memory](#input\_app\_instance\_memory) | The memory in MB for the App Runner instance (512, 1024, 2048, 3072, or 4096). | `number` | `2048` | no |
| <a name="input_app_max_concurrency"></a> [app\_max\_concurrency](#input\_app\_max\_concurrency) | The maximum number of concurrent requests per instance. | `number` | `100` | no |
| <a name="input_app_max_size"></a> [app\_max\_size](#input\_app\_max\_size) | The maximum number of instances for the App Runner service. | `number` | `10` | no |
| <a name="input_app_min_size"></a> [app\_min\_size](#input\_app\_min\_size) | The minimum number of instances for the App Runner service. | `number` | `1` | no |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | The port number that the application listens on. This port will be exposed by the container and used for incoming traffic. Common values: 3000 for Node.js, 8080 for Java, 5000 for Python. | `number` | `3000` | no |
| <a name="input_app_service_name"></a> [app\_service\_name](#input\_app\_service\_name) | The name of the App Runner service. | `string` | `"node-app-service"` | no |
| <a name="input_app_unhealthy_threshold"></a> [app\_unhealthy\_threshold](#input\_app\_unhealthy\_threshold) | The number of consecutive failed health checks before marking as unhealthy. | `number` | `5` | no |
| <a name="input_create_apprunner_service"></a> [create\_apprunner\_service](#input\_create\_apprunner\_service) | Whether to create the App Runner service. | `bool` | `true` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | The name of the ECR repository | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name (e.g., 'prod', 'staging', 'dev'). | `string` | `"prod"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | The tag of the Docker image in ECR (e.g., 'latest'). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apprunner_service_arn"></a> [apprunner\_service\_arn](#output\_apprunner\_service\_arn) | The ARN of the App Runner service. |
| <a name="output_apprunner_service_name"></a> [apprunner\_service\_name](#output\_apprunner\_service\_name) | The name of the App Runner service. |
| <a name="output_apprunner_service_url"></a> [apprunner\_service\_url](#output\_apprunner\_service\_url) | The default URL of the App Runner service. |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the ECR repository |
<!-- END_TF_DOCS -->