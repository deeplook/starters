
output "lambda_function_name" {
  value = aws_lambda_function.rekognition_lambda.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.rekognition_lambda.arn
}

output "lambda_policy_id" {
  value = aws_iam_role_policy.lambda_policy.id
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}
