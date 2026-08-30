# Contrato de la API - Ronda Segura

## Endpoints

### `GET /api/puntos`
Catálogo con coordenadas y radio, para trabajar sin conexión.
**Respuesta:** `200`
```json
[
  {
    "id": 1,
    "codigo": "PUNTO_1",
    "nombre": "Entrada Principal",
    "latitud": 4.6097,
    "longitud": -74.0817,
    "radio_m": 40,
    "orden": 1
  }
]
```

### `POST /api/rondas`
Abre una ronda para el usuario autenticado.
**Respuesta:** `201`
```json
{
  "id": "uuid...",
  "vence_en": "2026-08-29T17:00:00Z"
}
```

### `POST /api/rondas/:id/marcaciones`
Registra el escaneo y aplica la validación de geocerca.
**Body:**
```json
{
  "codigo": "PUNTO_1",
  "latitud": 4.6097,
  "longitud": -74.0817,
  "precisionM": 15,
  "escaneadaEn": "2026-08-29T16:00:00Z"
}
```
**Respuesta:**
- `201` si fue aceptada
- `422` si fue rechazada (fuera de rango)
```json
{
  "id": "uuid...",
  "rondaId": "uuid...",
  "puntoId": 1,
  "latitud": 4.6097,
  "longitud": -74.0817,
  "precisionM": 15,
  "distanciaM": 5.2,
  "aceptada": true,
  "motivoRechazo": null,
  "escaneadaEn": "2026-08-29T16:00:00Z"
}
```

### `GET /api/rondas/:id`
Estado de la ronda con puntos pendientes.
**Respuesta:** `200`
```json
{
  "id": "uuid...",
  "estado": "en_curso",
  "puntos_visitados": 1,
  "puntos_faltantes": 11,
  "tiempo_restante_minutos": 45
}
```

### `PATCH /api/rondas/:id/cerrar`
Cierra la ronda y calcula cumplimiento.
**Respuesta:** `200`
```json
{
  "cumplimiento": 100
}
```
