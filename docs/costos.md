# Estimación y Optimización de Costos

La arquitectura está diseñada bajo un modelo *Pay-as-you-go*, manteniendo los costos cercanos a $0.00 durante etapas de desarrollo y tráfico bajo.

## 1. Análisis de Servicios (AWS Free Tier)
* **AWS Lambda:** 1 millón de peticiones y 400,000 GB-segundos gratis al mes. 
* **Amazon API Gateway:** Primer millón de llamadas REST gratuitas al mes (durante 12 meses).
* **Amazon DynamoDB:** 25 GB de almacenamiento y 25 unidades de escritura/lectura gratuitas de por vida.
* **Amazon Cognito:** Primeros 50,000 MAUs (Usuarios Activos Mensuales) gratuitos.
* **Amazon CloudFront:** 1 TB de transferencia de datos de salida gratis al mes de por vida.

**Costo mensual estimado (hasta ~10,000 usuarios): $0.00 USD.**

## 2. Estrategias de Reducción de Costos Aplicadas
* **Sin servidores en reposo:** No hay EC2, RDS ni balanceadores de carga encendidos generando cobros por hora.
* **Retención de Logs:** Se recomienda añadir `retention_in_days = 7` a los recursos de CloudWatch Logs en Terraform para evitar cargos por almacenamiento infinito de registros antiguos.
* **Tamaño de la Lambda:** Configurada con una memoria baja (ej. 128MB a 256MB) ya que las operaciones (boto3) consumen poco procesamiento pero son de tipo I/O.

## 3. Alertas de Facturación (Budgets)
Se recomienda a nivel de cuenta configurar AWS Budgets enviando un correo cuando el gasto estimado exceda $1.00 USD para prevenir facturas sorpresa por picos inusuales de tráfico (DDoS).