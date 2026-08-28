import json
from app import lambda_handler

def test_health_check():
    # Simulamos el evento de API Gateway
    event = {"routeKey": "GET /healthz"}
    response = lambda_handler(event, None)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["status"] == "operativo"