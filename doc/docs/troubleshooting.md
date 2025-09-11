# Troubleshooting - FIWARE Dataspace

Este documento recopila los **problemas más comunes** encontrados durante el despliegue y ejecución del Dataspace, junto con sus soluciones.

---

## Durante el despliegue con Maven y K3s

### Error: `Timeout failed: docker run ... (timeout: PT30S)`
**Causa:** conexión lenta a internet al descargar imágenes de Docker.  

**Solución:**  
- Asegúrate de tener buena conexión.  
- Borrar todo y volver a ejecutar:  
```bash
mvn clean deploy -Plocal
```

### Error: `Pods en estado Pending`
**Causa:** Los PVCs (Persistent Volume Claims) no tienen un StorageClass asignado

**Solución:**
Asignar un storageclass por defecto
```bash
kubectl patch storageclass local-path \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Al volver a ejecutar un dataspace ya desplegado

### Error: `certificate signed by unknown authority`
**Causa:** El contexto perdió el certificado TLS

**Solución:** 
Recuperar el certificado correcto, por ejemplo:
```bash
docker exec k3s-keep cat /etc/rancher/k3s/k3s.yaml > ./k3s.yaml
export KUBECONFIG=$PWD/k3s.yaml
```

### Error: `Pods en estado uknown`
**Causa:** Los pods no han recuperado su estado natural.

**Solución:** 
Pueden recuperar su estado natural con el tiempo pero en caso de que esto no ocurra resetear pods:
```bash
 kubectl delete pod <nombre-pod> -n provider
```
Apisix no recupera su estado. Es necesario resetearlo siempre.

