# Uso de la API NGSI-LD con Scorpio Broker

El **Scorpio Broker** es el **Context Broker** del dataspace.  
Permite almacenar, consultar y suscribirse a entidades en formato **NGSI-LD**.

---

## Endpoints

- **Proveedor (Scorpio interno, acceso directo):**
http://scorpio-provider.127.0.0.1.nip.io:8080/ngsi-ld/v1


- **Marketplace (acceso vía APISIX, requiere token OIDC):**
http://mp-data-service.127.0.0.1.nip.io:8080/ngsi-ld/v1


---

## Crear una entidad

```bash
curl -s -X POST http://scorpio-provider.127.0.0.1.nip.io:8080/ngsi-ld/v1/entities \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
  "id": "urn:ngsi-ld:EnergyReport:fms-1",
  "type": "EnergyReport",
  "name": {
    "type": "Property",
    "value": "Standard Server"
  },
  "consumption": {
    "type": "Property",
    "value": "94"
  }
}'
```

## Consultar entidad por ID
```bash
curl -s http://scorpio-provider.127.0.0.1.nip.io:8080/ngsi-ld/v1/entities/urn:ngsi-ld:EnergyReport:fms-1 | jq
```

## Consultar con filtros
```bash
curl -s "http://scorpio-provider.127.0.0.1.nip.io:8080/ngsi-ld/v1/entities?type=EnergyReport" | jq
```

# Acceso seguro vía Marketplace (con token)
### 1. Obtener un data access token:
> 📄 Ejemplos de obtención y uso en [docs/tokens.md](docs/tokens.md).

### 2. Acceder vi marketplace
```shell
  curl -s -X GET 'http://mp-data-service.127.0.0.1.nip.io:8080/ngsi-ld/v1/entities/urn:ngsi-ld:EnergyReport:fms-1' \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer ${DATA_SERVICE_ACCESS_TOKEN}"
```

# Suscripciones
## Puedes crear suscripciones para recibir notificaciones cuando cambie una entidad:
```shell
curl -s -X POST http://scorpio-provider.127.0.0.1.nip.io:8080/ngsi-ld/v1/subscriptions \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "urn:ngsi-ld:Subscription:1",
    "type": "Subscription",
    "entities": [{ "type": "EnergyReport" }],
    "notification": {
      "endpoint": {
        "uri": "http://my-listener:8080/notify",
        "accept": "application/json"
      }
    }
  }'
```