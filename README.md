# Urban Mobility Data Hub — Dataspace Infrastructure

**Urban Mobility Data Hub (UMDH)** es una infraestructura basada en **FIWARE** y **Gaia-X** para el intercambio seguro y semántico de datos urbanos.  
Este repositorio contiene el **dataspace de referencia** utilizado en el proyecto, incluyendo los componentes de autenticación, intercambio y gestión de datos.

---

## Arquitectura general

El dataspace se basa en un conjunto de servicios interoperables que permiten la **publicación, descubrimiento y consumo de datos** entre entidades participantes.

![Diagrama de componentes](doc/img/diagrama-componentes.svg)

| Componente | Rol | Campo en el diagrama | Enlace |
|-------------|-----|----------------------|---------|
| **VCVerifier** | Valida las *Verifiable Credentials (VCs)* y las intercambia por tokens de acceso. | Verifier | [FIWARE/VCVerifier](https://github.com/FIWARE/VCVerifier) |
| **credentials-config-service** | Contiene la información sobre qué VCs son necesarias para acceder a cada servicio. | PRP/PAP (autenticación) | [FIWARE/credentials-config-service](https://github.com/FIWARE/credentials-config-service) |
| **Keycloak** | Emisor de *Verifiable Credentials* en el lado del consumidor y proveedor de identidad (IdP) basado en OIDC/OAuth2. | Issuer | [keycloak.org](https://www.keycloak.org) |
| **Scorpio (Orion-LD)** | *Context Broker* encargado de la gestión semántica de datos mediante NGSI-LD. | Context Broker | [ScorpioBroker](https://github.com/ScorpioBroker/ScorpioBroker) |
| **trusted-issuers-list** | Actúa como *Trusted Issuers List*, ofreciendo una API compatible con el registro de emisores de confianza (EBSI Trusted Issuers Registry API). | Lista local de emisores de confianza | [FIWARE/trusted-issuers-list](https://github.com/FIWARE/trusted-issuers-list) |
| **APISIX** | Pasarela API (API Gateway) que funciona como **PEP (Policy Enforcement Point)** e integra un plugin de OPA para control de acceso. | PEP | [apisix.apache.org](https://apisix.apache.org/) / [plugin OPA](https://apisix.apache.org/docs/apisix/plugins/opa/) |
| **OPA (Open Policy Agent)** | Motor de políticas que actúa como **PDP (Policy Decision Point)** en el *sidecar* del API Gateway. Evalúa las políticas de autorización. | PDP | [openpolicyagent.org](https://www.openpolicyagent.org/) |
| **odrl-pap** | Permite configurar políticas ODRL que serán utilizadas por OPA para la autorización. | PRP/PAP (autorización) | [wistefan/odrl-pap](https://github.com/wistefan/odrl-pap) |
| **tmforum-api** | Implementación de las APIs de TM Forum para la gestión de contratos, ofertas y productos. | Gestión de contratos | [FIWARE/tmforum-api](https://github.com/FIWARE/tmforum-api) |
| **contract-management** | Servicio de escucha y notificación de eventos relacionados con la gestión de contratos provenientes de TM Forum. | Gestión de contratos | [FIWARE/contract-management](https://github.com/FIWARE/contract-management) |
| **MySQL** | Base de datos relacional utilizada para almacenamiento estructurado de configuraciones o contratos. | Base de datos | [mysql.com](https://www.mysql.com) |
| **PostgreSQL** | Base de datos relacional avanzada para almacenamiento estructurado. | Base de datos | [postgresql.org](https://www.postgresql.org) |
| **PostGIS** | Extensión espacial de PostgreSQL que añade soporte geoespacial y consultas sobre datos geográficos. | Base de datos | [postgis.net](https://postgis.net/) |

# Guía de Despliegue del Dataspace

Esta guía explica cómo desplegar el entorno del **Dataspace** paso a paso, tanto en local como en un entorno de pruebas o producción.

---

!!! tip "Requisitos del sistema"
    Dado que el despliegue local instala **2 instancias de conector** y un **trust-anchor**, se recomienda utilizar una máquina lo suficientemente potente. Aunque **16 GB de RAM** podrían ser suficientes, se aconseja disponer de **más de 24 GB**. El despliegue se ha construido y probado en **Ubuntu**, aunque la mayoría de las demás distribuciones de Linux también deberían funcionar.

---

!!! info "Dependencias necesarias"
    El despliegue local intenta estar lo más **desacoplado posible del sistema anfitrión** para reducir los requisitos, pero aun así necesita los siguientes programas:
    - **Maven**  
    - **Java Development Kit (JDK)** — al menos **versión 17**  
    - **Docker**

---

!!! info "Herramientas recomendadas"
    Para interactuar con el sistema, también son útiles las siguientes herramientas:
    
    - **kubectl**  
    - **curl**  
    - **jq**  
    - **yq**

---

## Despliegue local

Clonar el repositorio:

```bash
git clone https://github.com/urban-mobility-data-hub/dataspace-infrastructure.git
```

Desplegar el dataspace:

```bash
mvn clean deploy -Plocal
```

Añadir el contexto a KUBECONFIG:

```bash
export  KUBECONFIG=$(pwd)/target/k3s.yaml
```

Ver despliegue en tiempo real:

```bash
watch kubectl get all --all-namespaces
```

```bash
NAMESPACE            NAME                                                        READY   STATUS      RESTARTS       AGE
cert-manager         cert-manager-6d988558d6-q7pcs                               1/1     Running     0              132m
cert-manager         cert-manager-cainjector-6976895488-dpwh4                    1/1     Running     0              132m
cert-manager         cert-manager-webhook-fcf48cc54-tj7tx                        1/1     Running     0              132m
cert-manager         trust-manager-775bfcf747-gpmqb                              1/1     Running     0              131m
consumer-a           did-helper-596df479dc-td66f                                 1/1     Running     0              114m
consumer-a           dsconfig-8fcdb84b7-pc26b                                    1/1     Running     0              114m
consumer-a           keycloak-0                                                  1/1     Running     0              114m
consumer-a           postgresql-0                                                1/1     Running     0              114m
ds-operator          mysql-0                                                     1/1     Running     0              130m
ds-operator          trusted-issuers-list-85c5765cb4-n7r8n                       1/1     Running     3 (128m ago)   130m
kube-system          coredns-76f75df574-g42xv                                    1/1     Running     0              134m
kube-system          coredns-76f75df574-sm58c                                    1/1     Running     0              134m
kube-system          etcd-cluster-minimal-ds-control-plane                       1/1     Running     0              134m
kube-system          kindnet-fqsmz                                               1/1     Running     0              134m
kube-system          kindnet-lxw8f                                               1/1     Running     0              134m
kube-system          kindnet-qvkll                                               1/1     Running     0              134m
kube-system          kube-apiserver-cluster-minimal-ds-control-plane             1/1     Running     0              134m
kube-system          kube-controller-manager-cluster-minimal-ds-control-plane    1/1     Running     0              134m
kube-system          kube-proxy-57vtq                                            1/1     Running     0              134m
kube-system          kube-proxy-c8cnv                                            1/1     Running     0              134m
kube-system          kube-proxy-jhz5b                                            1/1     Running     0              134m
kube-system          kube-scheduler-cluster-minimal-ds-control-plane             1/1     Running     0              134m
local-path-storage   local-path-provisioner-7577fdbbfb-8qxwq                     1/1     Running     0              134m
metallb-system       controller-67d9f4b5bc-fkq8n                                 1/1     Running     0              133m
metallb-system       speaker-lrqjr                                               1/1     Running     0              133m
metallb-system       speaker-tjdvg                                               1/1     Running     0              133m
metallb-system       speaker-wblpx                                               1/1     Running     0              133m
provider-a           apisix-proxy-control-plane-6f7664c8ff-nmx5g                 1/1     Running     0              126m
provider-a           apisix-proxy-data-plane-644f6d76dd-l6jxf                    2/2     Running     0              126m
provider-a           contract-management-6fdf575454-vjzkq                        1/1     Running     0              126m
provider-a           credentials-config-service-64bdb5d4f7-mr8sn                 1/1     Running     0              126m
provider-a           did-helper-7c88f8cfcd-5qssl                                 1/1     Running     0              126m
provider-a           dsconfig-8fcdb84b7-xg8f9                                    1/1     Running     0              126m
provider-a           fiware-data-space-connector-etcd-0                          1/1     Running     0              126m
provider-a           fiware-data-space-connector-etcd-1                          1/1     Running     0              126m
provider-a           fiware-data-space-connector-etcd-2                          1/1     Running     2 (121m ago)   126m
provider-a           mysql-db-0                                                  1/1     Running     0              126m
provider-a           pap-odrl-55745c6cb4-zvqbs                                   1/1     Running     0              126m
provider-a           postgis-db-0                                                1/1     Running     0              126m
provider-a           postgresql-db-0                                             1/1     Running     0              126m
provider-a           scorpio-broker-5ccf978d57-wm5bp                             1/1     Running     0              126m
provider-a           tm-forum-api-customer-bill-management-67d579485d-b8tqr      1/1     Running     0              126m
provider-a           tm-forum-api-customer-management-684564489f-qjmw8           1/1     Running     0              126m
provider-a           tm-forum-api-envoy-654894667-xf6m8                          1/1     Running     0              126m
provider-a           tm-forum-api-party-catalog-5d7754bbb-gn2sz                  1/1     Running     0              126m
provider-a           tm-forum-api-product-catalog-7b459df5f8-jxs9f               1/1     Running     0              126m
provider-a           tm-forum-api-product-inventory-8888bdf67-bj5qh              1/1     Running     0              126m
provider-a           tm-forum-api-product-ordering-management-56fd45cbb6-n9lh4   1/1     Running     0              126m
provider-a           tm-forum-api-registration-6pvn2                             0/1     Completed   0              119m
provider-a           tm-forum-api-registration-8mfs9                             0/1     Error       0              126m
provider-a           tm-forum-api-registration-k756g                             0/1     Error       0              120m
provider-a           tm-forum-api-registration-tvvb9                             0/1     Error       0              123m
provider-a           tm-forum-api-resource-catalog-77547c969f-dgcx8              1/1     Running     0              126m
provider-a           tm-forum-api-resource-function-activation-6d8d9ff64-7mxg9   1/1     Running     0              126m
provider-a           tm-forum-api-resource-inventory-7d74964c94-xvhqd            1/1     Running     0              126m
provider-a           tm-forum-api-service-catalog-86b94485d-5ngkh                1/1     Running     0              126m
provider-a           trusted-issuers-list-65b7fbd6fd-hbrxv                       1/1     Running     0              126m
provider-a           vc-verifier-7f8b6666db-n2vlb                                1/1     Running     0              126m
traefik-ingress      traefik-deployment-7489799fff-d4ffk                         1/1     Running     0              132m
```
