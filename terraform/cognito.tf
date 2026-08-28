# --- Amazon Cognito: Directorio de Usuarios ---

resource "aws_cognito_user_pool" "workshops_pool" {
  name = "${var.project_name}-${var.environment}-user-pool"

  # Queremos que los usuarios inicien sesión con su email (no con un username raro)
  username_attributes = ["email"]
  
  # Verificación automática del correo electrónico
  auto_verified_attributes = ["email"]

  # Políticas de contraseña (seguridad estándar)
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # Configuración del esquema: Hacemos que el email sea un campo obligatorio
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 5
      max_length = 2048
    }
  }

  # Cost Governance y Tags aplicados desde el provider automáticamente
}

# --- Amazon Cognito: Cliente para el Frontend (Next.js) ---

resource "aws_cognito_user_pool_client" "frontend_client" {
  name = "${var.project_name}-${var.environment}-frontend-client"

  user_pool_id = aws_cognito_user_pool.workshops_pool.id

  # IMPORTANTE: generate_secret DEBE ser false para aplicaciones web (SPA/Next.js) 
  # ya que el código vive en el navegador del cliente y no puede ocultar un secreto.
  generate_secret = false

  # Habilitamos los flujos de autenticación necesarios para el SDK de AWS o Amplify
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Prevenimos que nos cobren o bloqueen si hay errores, usando las reglas por defecto
  prevent_user_existence_errors = "ENABLED"
}