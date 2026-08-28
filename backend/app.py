import json
import os
import boto3
import uuid
from datetime import datetime

# Conexiones a AWS
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')
table = dynamodb.Table(table_name) if table_name else None

events_client = boto3.client('events')
event_bus = os.environ.get('EVENT_BUS_NAME')

def lambda_handler(event, context):
    route_key = event.get('routeKey', '')
    headers = { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    
    try:
        # --- RUTAS DE SALUD Y PRUEBAS ---
        if route_key == 'GET /healthz':
            return { "statusCode": 200, "headers": headers, "body": json.dumps({"status": "operativo", "version": "1.0"}) }
        
        # --- RUTA PÚBLICA: LEER TALLERES DE DYNAMODB ---
        if route_key == 'GET /workshops':
            # Escaneamos la tabla buscando solo los items que sean Talleres (SK = META)
            response = table.scan(
                FilterExpression="begins_with(PK, :prefix) AND SK = :sk",
                ExpressionAttributeValues={":prefix": "WORKSHOP#", ":sk": "META"}
            )
            return { 
                "statusCode": 200, 
                "headers": headers, 
                "body": json.dumps(response.get('Items', [])) 
            }
            
        # --- RUTA PROTEGIDA: GUARDAR TALLER EN DYNAMODB ---
        elif route_key == 'POST /workshops':
            body = json.loads(event.get('body', '{}'))
            nombre_taller = body.get("nombre", "Taller sin nombre")
            desc_taller = body.get("desc", "Sin descripción")
            
            # Generar un ID único para el taller
            workshop_id = str(uuid.uuid4())[:8]
            
            # Estructura Single-Table Design
            item = {
                "PK": f"WORKSHOP#{workshop_id}",
                "SK": "META",
                "id": workshop_id,
                "nombre": nombre_taller,
                "desc": desc_taller,
                "estado": "PROGRAMADO",
                "fecha_creacion": str(datetime.now())
            }
            
            # 1. Guardar en Base de Datos
            table.put_item(Item=item)
            
            # 2. Emitir evento asíncrono
            if event_bus:
                events_client.put_events(
                    Entries=[{
                        'Source': 'workshops.api',
                        'DetailType': 'WORKSHOP_CREATED',
                        'Detail': json.dumps({"taller": nombre_taller, "fecha_creacion": item['fecha_creacion']}),
                        'EventBusName': event_bus
                    }]
                )
                
            return {
                "statusCode": 201,
                "headers": headers,
                "body": json.dumps({"mensaje": f"Taller creado", "taller": item})
            }
            
        else:
            return { "statusCode": 404, "headers": headers, "body": json.dumps({"error": f"Ruta no encontrada"}) }
            
    except Exception as e:
        return { "statusCode": 500, "headers": headers, "body": json.dumps({"error": str(e)}) }