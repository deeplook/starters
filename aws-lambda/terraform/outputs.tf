output "lambda_function_name" {
  value = module.lambda_function.lambda_function_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.image_bucket.bucket
}
