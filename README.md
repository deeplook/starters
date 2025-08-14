# Starters

This is a collection of tested patterns, blueprints, recipes, you name it... for various services, frameworks and tools to get started and expand on more quickly. Each one has a testsuite and can be used with Docker. Installation commands are leaned toward brew on macOS, but should be easy to modify. Installed tools should be Docker, NodeJS, Python, Terraform (or OpenTofu), tflint, terraform-docs, pre-commit, jq, awscli...

## Content

In alphabetical order:

- [aws-apprunner](https://github.com/deeplook/starters/tree/main/aws-apprunner): A minimal example of a dummy NodeJS application, dockerized, pushed to AWS ECR and deployed as an AWS App Runner service (for single container applications).
- [aws-ec2](https://github.com/deeplook/starters/tree/main/aws-ec2): A minimal AWS EC2 instance running a vanilla Nginx server.
- [aws-ecs-fargate](https://github.com/deeplook/starters/tree/main/aws-ecs-fargate): An example of a small Python web application showing a dummy dashboard implemented with FastHTML/MonsterUI, dockerized, pushed to AWS ECR, installed on AWS ECS cluster with a load balancer.
- [fastapi-basic](https://github.com/deeplook/starters/tree/main/fastapi-basic): A minimal, FastAPI server implementing most HTTP methods.
- Hexagonal architecture, more to come...
- Twelve factor application, more to come...
