#!/bin/bash

set -e

echo "=========================================="
echo "Destroying E-commerce Microservices"
echo "=========================================="
echo ""

echo "WARNING: This will delete all resources in the 'ecommerce' namespace."
echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
sleep 5
echo ""

echo "Step 1: Deleting microservices..."
kubectl delete -f user-service/user-service-service.yaml --ignore-not-found=true
kubectl delete -f user-service/user-service-deployment.yaml --ignore-not-found=true
kubectl delete -f product-service/product-service-service.yaml --ignore-not-found=true
kubectl delete -f product-service/product-service-deployment.yaml --ignore-not-found=true
kubectl delete -f order-service/order-service-service.yaml --ignore-not-found=true
kubectl delete -f order-service/order-service-deployment.yaml --ignore-not-found=true
echo ""

echo "Step 2: Deleting databases..."
kubectl delete -f postgres/postgres-service.yaml --ignore-not-found=true
kubectl delete -f postgres/postgres-deployment.yaml --ignore-not-found=true
kubectl delete -f mongo/mongodb-service.yaml --ignore-not-found=true
kubectl delete -f mongo/mongodb-deployment.yaml --ignore-not-found=true
echo ""

echo "Step 3: Deleting persistent volume claims..."
kubectl delete -f postgres/postgres-pvc.yaml --ignore-not-found=true
kubectl delete -f mongo/mongodb-pvc.yaml --ignore-not-found=true
echo ""

echo "Step 4: Deleting secrets..."
kubectl delete -f postgres/postgres-secret.yaml --ignore-not-found=true
kubectl delete -f mongo/mongodb-secret.yaml --ignore-not-found=true
echo ""

echo "Step 5: Checking remaining resources..."
kubectl get all -n ecommerce
echo ""

echo "=========================================="
echo "Resources Deleted!"
echo "=========================================="
echo ""
echo "Note: Namespace 'ecommerce' still exists."
echo "To delete the namespace completely, run:"
echo "  kubectl delete namespace ecommerce"
echo ""
echo "To delete persistent volume data, run:"
echo "  kubectl delete pv --all"
