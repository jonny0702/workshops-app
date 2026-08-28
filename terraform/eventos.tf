# --- 1. SNS: Sistema de Notificaciones (Email) ---
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-${var.environment}-notifications"
}

# Suscripción para enviarte un correo cuando ocurra el evento
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = "jonathanvergararuiz@gmail.com" # 
}

# --- 2. EventBridge: El Bus Central de Eventos ---
resource "aws_cloudwatch_event_bus" "event_bus" {
  name = "${var.project_name}-${var.environment}-bus"
}

# Regla: "Escucha a cualquiera que grite WORKSHOP_CREATED"
resource "aws_cloudwatch_event_rule" "workshop_created_rule" {
  name           = "workshop-created-rule"
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  description    = "Captura eventos de talleres creados"

  event_pattern = jsonencode({
    source      = ["workshops.api"]
    detail-type = ["WORKSHOP_CREATED"]
  })
}

# Destino: "Si escuchas la regla anterior, envíalo a SNS"
resource "aws_cloudwatch_event_target" "sns_target" {
  rule           = aws_cloudwatch_event_rule.workshop_created_rule.name
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  target_id      = "SendToSNS"
  arn            = aws_sns_topic.notifications.arn
}

# Permiso para que EventBridge pueda publicar en SNS
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action = "sns:Publish"
      Resource = aws_sns_topic.notifications.arn
    }]
  })
}