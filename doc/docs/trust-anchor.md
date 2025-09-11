# 🛡️ Trust Anchor en el Dataspace FIWARE

El **Trust Anchor** es el componente central encargado de mantener la **confianza** dentro del ecosistema de un dataspace.  
Se encarga de almacenar y validar la información sobre los participantes, los emisores de credenciales y las políticas de confianza aplicadas.

---

## Funcionalidad principal

- **Trusted Issuers Registry (TIR)**  
  - Registra y publica los **emisores de credenciales confiables**.  
  - Cada emisor (ej. un proveedor de identidad) debe estar listado en este registro.  

- **Trusted Issuers List (TIL)**  
  - Gestiona las listas de emisores autorizados que pueden validar credenciales.  
  - Permite crear, actualizar y eliminar emisores de confianza.  
  - En un entorno real, este endpoint no debería ser público.  

- **MySQL persistente**  
  - El Trust Anchor utiliza una base de datos MySQL (con PVC activado) para mantener los registros entre reinicios.  
  - Esto garantiza que los emisores y listas configurados **no se pierdan**.

---

## Endpoints principales

| Componente | URL local | Descripción |
|------------|-----------|-------------|
| TIR (Trusted Issuers Registry) | [http://tir.127.0.0.1.nip.io:8080/](http://tir.127.0.0.1.nip.io:8080/) | Publica el listado de emisores de confianza. |
| TIL (Trusted Issuers List API) | [http://til.127.0.0.1.nip.io:8080/](http://til.127.0.0.1.nip.io:8080/) | API de gestión (alta, baja, edición) de emisores de confianza. |

> ⚠️ **Nota:**  
> En un dataspace productivo, **TIL no debería estar expuesto** al exterior, ya que se usa solo para administración.

---

## Flujo de confianza

1. El **Trust Anchor** publica el listado de emisores (TIR).  
2. Los **verificadores** consultan este listado para validar credenciales.  
3. Los **emisores confiables** son gestionados desde la API TIL.  
4. La información queda registrada en la base de datos MySQL persistente.

---

## Ejemplos de Uso

Obtener una lista de issuers:
```bash
    curl -X GET http://tir.127.0.0.1.nip.io:8080/v4/issuers | python3 -m json.tool
```

Registrar un nuevo issuer:

```bash
  curl -X POST http://til.127.0.0.1.nip.io:8080/issuer \
    --header 'Content-Type: application/json' \
    --data '{
      "did": "did:key:myKey",
      "credentials": []
    }'  | python3 -m json.tool
```
---

## Referencias

- [FIWARE Trust Anchor - GitHub](https://github.com/FIWARE/trust-anchor)
- [FIWARE Dataspaces Documentation](https://github.com/FIWARE/tutorials.Dataspaces)

