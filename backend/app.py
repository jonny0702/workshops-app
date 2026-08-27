import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')
table = dynamodb.Table(table_name) if table_name else None

def lambda_handler(event, context):
    print(f"Evento recibido: {json.dumps(event)}")
    
    route_key = event.get('routeKey', '')
    
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" 
    }
    
    try:
        # --- RUTA PÚBLICA ---
        if route_key == 'GET /workshops':
            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({"mensaje": "Éxito: Lista de talleres obtenida (Ruta Pública)"})
            }
            
        # --- RUTA PROTEGIDA (Requiere token de Cognito) ---
        elif route_key == 'POST /workshops':
            body = json.loads(event.get('body', '{}'))
            return {
                "statusCode": 201,
                "headers": headers,
                "body": json.dumps({
                    "mensaje": "Éxito: Taller creado (Ruta Protegida por Cognito)", 
                    "datos_recibidos": body
                })
            }
            
        else:
            return {
                "statusCode": 404,
                "headers": headers,
                "body": json.dumps({"error": f"Ruta no encontrada: {route_key}"})
            }
            
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": str(e)})
        }