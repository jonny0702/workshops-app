# Operación, Monitoreo y Respuestas a Incidentes

## 1. Alarmas y Dashboards
La infraestructura cuenta con recursos de observabilidad creados por Terraform:
* **Dashboard (CloudWatch):** Muestra invocaciones, latencia y errores de la API.
* **Alarmas:** `api-errors` se activa si la Lambda arroja un `HTTP 500`. Envia una notificación al correo del administrador vía SNS.

## 2. Runbook: Respuesta a Incidentes
**Incidente:** Alerta recibida por correo desde SNS por errores en la API.
**Acciones:**
1. Ingresar a AWS Console > CloudWatch > Log Groups.
2. Buscar el Log Group `/aws/lambda/workshops-app-prod-api-handler`.
3. Filtrar por `ERROR` o `Traceback` para identificar si el fallo es de código o de permisos (ej. fallo de comunicación con DynamoDB).
4. Revertir el último merge en GitHub (`git revert`) si el error coincide con un despliegue reciente.

## 3. Estrategia de Backup (DynamoDB)
Debido a la naturaleza de los datos, las copias de seguridad de DynamoDB se gestionan *On-Demand* mediante AWS CLI.

**Crear un Backup:**
```bash
aws dynamodb create-backup \
    --table-name workshops-app-prod-table \
    --backup-name BackupManual-AntesDeMigracion
```
**Restaurar desde un Backup:**
```bash
aws dynamodb restore-table-from-backup \
    --target-table-name workshops-app-prod-table-restored \
    --backup-arn <ARN_DEL_BACKUP>
```