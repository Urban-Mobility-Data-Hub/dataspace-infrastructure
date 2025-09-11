# Keycloak en el Dataspace FIWARE

Keycloak es el componente encargado de la **gestión de identidades y control de acceso** en el dataspace.  
Se utiliza para autenticar usuarios y servicios, emitir tokens OIDC y proteger el acceso a datos a través de APISIX.

---

## Funciones principales
- Proporciona un **Identity Provider (IdP)** basado en estándares: OIDC, OAuth2 y SAML.  
- Gestiona **usuarios, clientes y roles**.  
- Emite **Access Tokens** y **Refresh Tokens** que se usan para acceder a los servicios del dataspace.  
- Se integra con **APISIX** para proteger los endpoints públicos.  

---

## Acceso al servicio

El servicio Keycloak está expuesto en el dataspace mediante Ingress:

- **Consumer Keycloak:**  
  `https://keycloak-consumer.127.0.0.1.nip.io`

- **Provider Keycloak:**  
  `https://keycloak-provider.127.0.0.1.nip.io`

> ⚠️ Nota: la consola web `/auth/` puede no estar accesible directamente. Para la mayoría de casos se recomienda usar la **Admin API** o los clientes configurados vía `values.yaml`.

---

## Credenciales de prueba

El despliegue incluye por defecto un **realm de prueba** (`test-realm`) con usuarios y clientes preconfigurados:

- Usuario: `employee`  
- Contraseña: `test`  
- Cliente de ejemplo: `account-console`

---

## Obtener un Data Access Token

> 📄 Ejemplos de obtención y uso en [docs/tokens.md](docs/tokens.md).



