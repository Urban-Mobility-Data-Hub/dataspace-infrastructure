#!/bin/bash
# Script: ejecutar_ds.sh
# Arranca el contenedor del cluster y limpia pods Unknown o CrashLoopBackOff con reintentos

set -e

CONTAINER_NAME="k3s-maven-plugin"
MAX_RETRIES=3   # Número máximo de reintentos
WAIT_TIME=30    # Segundos de espera entre reintentos

echo "🚀 Arrancando contenedor $CONTAINER_NAME..."
docker start $CONTAINER_NAME

export KUBECONFIG=$HOME/fiware-dataspace/target/k3s.yaml

echo "⏳ Esperando 20 segundos a que k3s esté disponible..."
sleep 20

# Función que reinicia pods problemáticos
reset_pods() {
  pods_problem=$(kubectl get pods -A --no-headers | awk '$4=="Unknown" || $4=="CrashLoopBackOff"{print $1" "$2}')

  if [ -z "$pods_problem" ]; then
    return 1  # no hay pods problemáticos
  fi

  echo "⚠️  Reiniciando pods problemáticos:"
  echo "$pods_problem"

  while read -r ns pod; do
    [[ -z "$ns" || -z "$pod" ]] && continue

    # Lista de pods críticos que no se borran a lo bruto
    if [[ "$pod" == *etcd* ]]; then
      echo "⏭️  Saltando pod crítico: $pod ($ns)"
      continue
    fi

    echo "   ➝ Reiniciando $pod en namespace $ns"
    owner_kind=$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null || echo "")

    if [[ "$owner_kind" == "Deployment" ]]; then
      deploy=$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{.metadata.ownerReferences[0].name}')
      kubectl rollout restart deployment "$deploy" -n "$ns"
    elif [[ "$owner_kind" == "StatefulSet" ]]; then
      sts=$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{.metadata.ownerReferences[0].name}')
      kubectl rollout restart statefulset "$sts" -n "$ns"
    else
      kubectl delete pod "$pod" -n "$ns" --grace-period=0
    fi
  done <<< "$pods_problem"

  return 0  # se reinició algo
}

# Bucle de reintentos
for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "🔄 Iteración $i de $MAX_RETRIES"
  reset_pods || {
    echo "✅ No hay pods problemáticos."
    break
  }

  echo "⏳ Esperando $WAIT_TIME segundos para verificar..."
  sleep $WAIT_TIME
done

echo
echo "✅ Estado final de los pods:"
kubectl get pods -A
