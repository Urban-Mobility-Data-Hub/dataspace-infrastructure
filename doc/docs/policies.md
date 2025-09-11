# Políticas ODRL en el Dataspace

Las **políticas ODRL (Open Digital Rights Language)** permiten definir **qué datos pueden compartirse, bajo qué condiciones y restricciones**.  
En el dataspace FIWARE, estas políticas se gestionan a través del **ODRL Policy Administration Point (PAP)** y se aplican en combinación con **APISIX** y **Scorpio**.

---

## Componentes relacionados
- **ODRL PAP**: servicio que gestiona políticas en formato ODRL.  
- **APISIX**: aplica las políticas para controlar el acceso a endpoints.  
- **Scorpio Broker**: los datos que publiques estarán sujetos a las políticas registradas.  

---

## Funcionamiento

### Cuando una política está activa:

El cliente debe obtener un Data Access Token válido. > 📄 Ejemplos de obtención y uso en [docs/tokens.md](docs/tokens.md).

APISIX intercepta la petición y consulta las políticas en el PAP.

Si el token y la política lo permiten → la petición se reenvía a Scorpio.

Si no → se devuelve un 403 Forbidden.

---

## Crear una política simple

Ejemplo de política que permite el acceso **sólo a usuarios con rol `employee`**:

```bash
curl -s -X POST http://pap-provider.127.0.0.1.nip.io:8080/policies \
  -H "Content-Type: application/json" \
  -d '{
    "@context": "http://www.w3.org/ns/odrl.jsonld",
    "uid": "urn:odrl:policy:energy-read",
    "type": "Set",
    "permission": [{
      "target": "urn:ngsi-ld:EnergyReport:fms-1",
      "action": "read",
      "assignee": "employee"
    }]
  }'
```

## Política con restricción temporal
Ejemplo de política que permite acceso sólo hasta el 31/12/2025:
```bash
curl -s -X POST http://pap-provider.127.0.0.1.nip.io:8080/policies \
  -H "Content-Type: application/json" \
  -d '{
    "@context": "http://www.w3.org/ns/odrl.jsonld",
    "uid": "urn:odrl:policy:temporal-access",
    "type": "Set",
    "permission": [{
      "target": "urn:ngsi-ld:EnergyReport:fms-1",
      "action": "read",
      "constraint": [{
        "leftOperand": "dateTime",
        "operator": "lteq",
        "rightOperand": "2025-12-31T23:59:59Z"
      }]
    }]
  }'
```

## Prohibición de uso
Ejemplo de política que prohíbe compartir un recurso concreto:
```bash
curl -s -X POST http://pap-provider.127.0.0.1.nip.io:8080/policies \
  -H "Content-Type: application/json" \
  -d '{
    "@context": "http://www.w3.org/ns/odrl.jsonld",
    "uid": "urn:odrl:policy:no-share",
    "type": "Set",
    "prohibition": [{
      "target": "urn:ngsi-ld:EnergyReport:fms-1",
      "action": "share"
    }]
  }'
```

## Consultar políticas existentes
```bash
curl -s http://pap-provider.127.0.0.1.nip.io:8080/policies | jq
```
