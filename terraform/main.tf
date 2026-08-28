terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # 2. El estado remoto (S3)
  backend "s3" {
    bucket = "terraform-state-s3-workshop" # Reemplaza con el nombre de tu bucket real
    key    = "workshops/terraform.tfstate"
    region = "us-east-1"
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

