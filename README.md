# WORKSHOP APP

## 📚 Documentación del Proyecto

Para explorar en profundidad las decisiones técnicas, el diseño de la infraestructura y las guías operativas, consulta los siguientes documentos:

* **[Arquitectura y Seguridad](./docs/arquitectura.md):** Diagramas del sistema, decisiones de diseño (Serverless, EventBridge) y configuración de seguridad (Cognito, IAM, OAC).
* **[Referencia de la API](./docs/api.md):** Contratos de comunicación REST, métodos de autenticación (JWT) y ejemplos de consumo para los endpoints de talleres.
* **[Despliegue y CI/CD](./docs/despliegue.md):** Explicación del flujo de trabajo automatizado con GitHub Actions, separación de entornos (Dev/Prod) y comandos de Terraform.
* **[Operaciones y Monitoreo](./docs/operacion.md):** Dashboards, alertas de CloudWatch Logs, runbooks de respuesta a incidentes y estrategias de backup *On-Demand* para DynamoDB.
* **[Optimización de Costos](./docs/costos.md):** Análisis financiero del entorno Serverless en la capa gratuita (AWS Free Tier) y configuraciones para mantener la facturación operativa en $0.00.