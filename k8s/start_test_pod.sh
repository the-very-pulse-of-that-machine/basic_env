#!/usr/bin/env bash
set -e

POD_NAME=91mrqiao-test-pod
NAMESPACE=default
YAML=test_pod.yaml
LOCAL_PORT=8080
POD_PORT=8080

echo "🚀 Apply Pod..."
#kubectl apply -f $YAML

echo "⏳ Waiting for Pod to be Ready..."
#kubectl wait --for=condition=Ready pod/$POD_NAME -n $NAMESPACE --timeout=300s

echo "🧠 Starting code-server inside Pod..."

kubectl exec 91mrqiao-test-pod -- bash -lc ''

echo "🔌 Port forwarding localhost:${LOCAL_PORT} -> pod:${POD_PORT}"
kubectl port-forward -n default pod/91mrqiao-test-pod 8080:8080


