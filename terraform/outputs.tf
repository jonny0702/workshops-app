output "dynamodb_table_name" {
  description = "Nombre de la tabla de DynamoDB"
  value       = aws_dynamodb_table.main_table.name
}