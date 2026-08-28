import json
import os
import boto3
from datetime import datetime

# Conexión a DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')
table = dynamodb.Table(table_name) if table_name else None

# NUEVO: Conexión al bus de eventos de EventBridge
events_client = boto3.client('events')
event_bus = os.environ.get('EVENT_BUS_NAME')

def lambda_handler(event, context):
    print(f"Evento recibido: {json.dumps(event)}")
    route_key = event.get('routeKey', '')
    headers = { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    
    try:
        if route_key == 'GET /workshops':
            return { "statusCode": 200, "headers": headers, "body": json.dumps({"mensaje": "Éxito: Lista de talleres obtenida"}) }
            
        elif route_key == 'POST /workshops':
            body = json.loads(event.get('body', '{}'))
            nombre_taller = body.get("nombre", "Taller sin nombre")
            
            # 1. Aquí iría el código para guardar en DynamoDB (lo haremos luego)
            
            # 2. NUEVO: Emitimos el evento asíncrono a EventBridge
            if event_bus:
                events_client.put_events(
                    Entries=[{
                        'Source': 'workshops.api',
                        'DetailType': 'WORKSHOP_CREATED',
                        'Detail': json.dumps({
                            "taller": nombre_taller, 
                            "fecha_creacion": str(datetime.now())
                        }),
                        'EventBusName': event_bus
                    }]
                )
                
            return {
                "statusCode": 201,
                "headers": headers,
                "body": json.dumps({"mensaje": f"Taller '{nombre_taller}' creado y evento emitido."})
            }
            
        else:
            return { "statusCode": 404, "headers": headers, "body": json.dumps({"error": f"Ruta no encontrada: {route_key}"}) }
            
    except Exception as e:
        return { "statusCode": 500, "headers": headers, "body": json.dumps({"error": str(e)}) }