# Bases de Datos en el Dataspace FIWARE

El dataspace utiliza varias **bases de datos persistentes** para almacenar información crítica:  
- Credenciales y usuarios (Keycloak).  
- Metadatos de entidades NGSI-LD (Scorpio).  
- Configuración y contratos (otros servicios del conector).  

Todas las bases de datos han sido configuradas con **Persistent Volume Claims (PVCs)** para que los datos **se conserven entre reinicios**.

---

## Bases de datos principales

### Keycloak (MySQL)
- Almacena usuarios, clientes, realms y roles.  
- Garantiza que los usuarios y configuraciones de autenticación **no se pierdan** si el pod se reinicia.  
- PVC: `data-authentication-mysql-0`

---

### Scorpio Broker (PostGIS)
- Context Broker **NGSI-LD**.  
- Guarda las entidades publicadas (por ejemplo, `urn:ngsi-ld:EnergyReport:fms-1`).  
- Usa PostgreSQL con extensión PostGIS para datos geoespaciales.  
- PVC: `data-data-service-postgis-0`

---

### Contract Management (PostgreSQL)
- Gestiona contratos y acuerdos entre participantes.  
- Base de datos Postgres dedicada al módulo Contract Management.  
- PVC: `data-postgresql-0`

---

### Trust Anchor (MySQL)
- Almacena emisores confiables (TIR/TIL).  
- Garantiza que los registros de **Trusted Issuers** no desaparezcan entre reinicios.  
- PVC: `data-trust-anchor-mysql-0`

---

### MongoDB
- Usado por servicios auxiliares (ej. credenciales, registro temporal).  
- PVC: `mongodb`

---

### Etcd
- Base distribuida usada por algunos componentes para coordinación interna.  
- Mantiene el estado de configuración de forma replicada.  
- PVCs:  
  - `data-provider-etcd-0`  
  - `data-provider-etcd-1`  
  - `data-provider-etcd-2`

---

## Verificación de PVCs

Para comprobar que los volúmenes están activos y ligados:

```bash
kubectl get pvc -A
