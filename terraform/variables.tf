variable "aws_region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "environment" {
  description = "Entorno (dev, prod)"
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto para las etiquetas"
  default     = "workshops-app"
}