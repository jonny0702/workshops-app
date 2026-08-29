# Guía de Despliegue y CI/CD

Este proyecto utiliza infraestructura como código (IaC) con Terraform y un pipeline automatizado mediante GitHub Actions.

## 1. Requisitos Previos
* Cuenta en AWS configurada (Access Keys).
* Terraform instalado (`>= 1.5.0`).
* Node.js (`>= 20.0.0`) para construir el frontend local.
* Bucket de S3 externo pre-creado para el Estado de Terraform (`backend "s3"`).

## 2. Flujo de Trabajo (GitFlow)
El pipeline en `.github/workflows/main.yml` automatiza el paso a producción:

1. **Development (`development` branch):** Un push ejecuta Linters y Tests. Si es exitoso, Terraform despliega en AWS (Entorno `dev`) y crea un PR automático hacia `main`.
2. **Producción (`main` branch):** Al hacer merge del PR, el pipeline redespliega la infraestructura apuntando a variables de producción, invalida CloudFront, y ejecuta un Smoke Test contra `/healthz`.

## 3. Despliegue Manual (Romper el cristal)
En caso de emergencia (falla del CI/CD), se puede desplegar manualmente:

```bash
# 1. Desplegar Infraestructura (Backend)
cd terraform
terraform init
terraform apply -var="environment=prod"

# 2. Desplegar Frontend
cd ../frontend
npm run build
aws s3 sync out/ s3://<TU-BUCKET-FRONTEND-PROD> --delete

# 3. Limpiar CDN
aws cloudfront create-invalidation --distribution-id <TU-DISTRIBUCION> --paths "/*"
```