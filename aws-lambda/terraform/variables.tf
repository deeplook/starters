variable "aws_region" {
  type        = string
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create."
  default     = "rekognition-images-cli"
}
