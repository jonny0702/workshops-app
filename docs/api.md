# Documentación de la API

Base URL (Producción): `https://[API-ID].execute-api.us-east-1.amazonaws.com`

## Autenticación
Los endpoints protegidos requieren un token JWT en las cabeceras de la petición:
`Authorization: <tu-token-jwt>`

### Prueba de API con GateWay ID
**GET**/ https://1s3qwi2wjf.execute-api.us-east-1.amazonaws.com//workshops
---

## 1. Endpoints de Monitoreo

### `GET /healthz`
Comprueba la salud del backend (Smoke Test).
* **Autenticación:** Ninguna (Pública)
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "status": "operativo",
    "version": "1.0"
  }
  ```

---

## 2. Endpoints de Talleres

### `GET /workshops`
Obtiene la lista de talleres disponibles.
* **Autenticación:** Ninguna (Pública)
* **Respuesta Exitosa (200 OK):**
  ```json
  [
    {
      "PK": "WORKSHOP#1234abcd",
      "SK": "META",
      "id": "1234abcd",
      "nombre": "Bootcamp AWS",
      "desc": "Aprende arquitectura serverless",
      "estado": "PROGRAMADO"
    }
  ]
  ```

### `POST /workshops`
Crea un nuevo taller y emite un evento al bus de EventBridge.
* **Autenticación:** Requerida (JWT)
* **Body de la Petición:**
  ```json
  {
    "nombre": "Masterclass Terraform",
    "desc": "Despliegue de infraestructura como código"
  }
  ```
* **Respuesta Exitosa (201 Created):**
  ```json
  {
    "mensaje": "Taller creado",
    "taller": {
      "id": "5678efgh",
      "nombre": "Masterclass Terraform",
      "estado": "PROGRAMADO"
    }
  }
  ```