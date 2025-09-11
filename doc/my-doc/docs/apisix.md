# APISIX en el Dataspace FIWARE

**Apache APISIX** es el **API Gateway** utilizado en el dataspace FIWARE.  
Se encarga de interceptar todas las peticiones externas y aplicar:

- **Autenticación** → Verifica los tokens OIDC emitidos por Keycloak.  
- **Autorización** → Aplica las políticas ODRL registradas en el PAP.  
- **Enrutamiento** → Redirige las peticiones al servicio correspondiente (Scorpio, TIR, Marketplace, etc.).  
- **Observabilidad** → Métricas y logs centralizados del tráfico.

---

## Endpoints internos

Son los services de Kubernetes o Ingress directos que exponen los pods sin pasar por la capa de seguridad (Keycloak + APISIX).

Acceso directo a los brokers, bases de datos o servicios auxiliares.

### Ejemplos:
```bash
http://scorpio-provider.127.0.0.1.nip.io:8080/ngsi-ld/v1/... → acceso directo al Context Broker (Scorpio).

http://keycloak-provider.127.0.0.1.nip.io:8080/ → acceso directo al Keycloak del provider.

http://til.127.0.0.1.nip.io:8080/ → Trusted Issuers List API (gestión interna del Trust Anchor).
```


## Endpoints externos

Son los que expone APISIX como API Gateway.

Incluyen autenticación OIDC en Keycloak y autorización basada en ODRL.

Son los oficiales en producción, porque garantizan la seguridad del dataspace.

### Ejemplos:
```bash
http://mp-data-service.127.0.0.1.nip.io:8080/ngsi-ld/v1/...
→ acceso a entidades NGSI-LD a través de APISIX + policies ODRL.

https://marketplace.127.0.0.1.nip.io:8443/
→ acceso al Marketplace (BAE), protegido por tokens.

https://keycloak-consumer.127.0.0.1.nip.io:8443/
→ acceso al Keycloak del consumer (interfaz de login).
```

