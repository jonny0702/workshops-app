resource "aws_dynamodb_table" "main_table" {
  name           = "${var.project_name}-${var.environment}-table"
  billing_mode   = "PROVISIONED" # Para asegurar que entra en el Free Tier (25 WCU/RCU gratis)
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "PK"
  range_key      = "SK"

  # Llaves principales
  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  # Atributo para el Índice Global (Para filtrar talleres por fecha)
  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  # GSI1: Para consultar listar talleres ordenados por fecha
  global_secondary_index {
    name               = "GSI1"
    hash_key           = "GSI1PK" # Aquí guardaremos "WORKSHOP#ALL"
    range_key          = "GSI1SK" # Aquí guardaremos la fecha "startAt"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }

  # Evita que Terraform la destruya por accidente (comentado para el lab, descomentar en PROD)
  # deletion_protection_enabled = true 
}