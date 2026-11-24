#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="docker-desktop"

#echo "=== [1/4] Checking prerequisites ==="
#command -v kind >/dev/null 2>&1 || { echo "kind not found. Run 'brew install kind'"; exit 1; }
#command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found."; exit 1; }
#
#echo "=== [2/4] Ensuring kind cluster exists ==="
#if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
#  echo "Creating kind cluster '${CLUSTER_NAME}'..."
#  kind create cluster --name "${CLUSTER_NAME}"
#else
#  echo "Cluster '${CLUSTER_NAME}' already exists. Using current cluster."
#fi

kubectl cluster-info --context ${CLUSTER_NAME}
kubectl config current-context

echo "=== [3/4] Creating namespace with PSS Restricted baseline & LimitRange ==="
kubectl apply -f 00-namespace-baseline.yaml

echo "=== [4/4] Deploying inherited workloads (Observe rejections and failures in Headlamp!) ==="
kubectl apply -f 01-api-gateway.yaml || true
kubectl apply -f 02-order-processor.yaml || true
kubectl apply -f 03-payment-service.yaml || true
kubectl apply -f 04-background-worker.yaml || true
kubectl apply -f 05-legacy-pdf-generator.yaml || true
kubectl apply -f 06-mesh-telemetry-agent.yaml || true
kubectl apply -f 07-cache-cleaner.yaml || true
kubectl apply -f 08-reporting-batch.yaml || true

echo ""
echo "=========================================================================="
echo "Deployment complete! Open Headlamp, connect to 'kind-${CLUSTER_NAME}',"
echo "and inspect the 'secure-apps' namespace under Pods, Workloads, and Events."
echo "=========================================================================="
