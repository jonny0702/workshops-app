terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Cost Governance: Todas las etiquetas se aplicarán a todo lo que creemos
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # NUEVO: Guarda la memoria de Terraform en AWS
  backend "s3" {
    bucket = "terraform-state-s3-workshop" # Cambia por el nombre exacto que creaste
    key    = "workshops/terraform.tfstate"
    region = "us-east-1"
  }
}