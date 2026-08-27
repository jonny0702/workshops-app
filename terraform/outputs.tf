output "dynamodb_table_name" {
  description = "Nombre de la tabla de DynamoDB"
  value       = aws_dynamodb_table.main_table.name
}
output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = aws_cognito_user_pool.workshops_pool.id
}

output "cognito_client_id" {
  description = "ID del App Client para Next.js"
  value       = aws_cognito_user_pool_client.frontend_client.id
}
output "api_gateway_url" {
  description = "URL base de tu API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}