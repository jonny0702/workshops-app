# --- 1. Empaquetar el código Python ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../backend" # Va a buscar la carpeta backend que está un nivel arriba
  output_path = "backend.zip"
}

# --- 2. Permisos IAM para la Lambda ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-${var.environment}-dynamodb-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Scan", "dynamodb:Query", "dynamodb:UpdateItem", "dynamodb:DeleteItem"]
        Resource = [aws_dynamodb_table.main_table.arn, "${aws_dynamodb_table.main_table.arn}/index/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["events:PutEvents"]
        Resource = aws_cloudwatch_event_bus.event_bus.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# --- 3. Función Lambda ---
resource "aws_lambda_function" "api_handler" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-api-handler"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.main_table.name # Inyección automática
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.event_bus.name
    }
  }
}

# --- 4. API Gateway (HTTP API - v2) ---
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"] # Para Next.js
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_handler.invoke_arn
  payload_format_version = "2.0"
}

# --- 5. Autorizador de Cognito ---
resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id           = aws_apigatewayv2_api.http_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.frontend_client.id]
    issuer   = "https://${aws_cognito_user_pool.workshops_pool.endpoint}"
  }
}

# --- 6. Rutas de la API ---

# Ruta GET (Pública)
resource "aws_apigatewayv2_route" "get_workshops" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /workshops"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Ruta POST (Protegida)
resource "aws_apigatewayv2_route" "post_workshops" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /workshops"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

# --- 7. Permiso para que API Gateway despierte a la Lambda ---
resource "aws_lambda_permission" "api_gw_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}