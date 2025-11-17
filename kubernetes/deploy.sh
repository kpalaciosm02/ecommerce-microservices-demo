#!/bin/bash

set -e

echo "=========================================="
echo "Deploying E-commerce Microservices to K8s"
echo "=========================================="
echo ""

echo "Step 1: Creating namespace..."
kubectl apply -f namespace.yaml
echo ""

echo "Step 2: Creating secrets..."
kubectl apply -f postgres/postgres-secret.yaml
kubectl apply -f mongo/mongodb-secret.yaml
echo ""

echo "Step 3: Creating persistent volume claims..."
kubectl apply -f postgres/postgres-pvc.yaml
kubectl apply -f mongo/mongodb-pvc.yaml
echo ""

echo "Step 4: Deploying databases..."
kubectl apply -f postgres/postgres-deployment.yaml
kubectl apply -f postgres/postgres-service.yaml
kubectl apply -f mongo/mongodb-deployment.yaml
kubectl apply -f mongo/mongodb-service.yaml
echo ""

echo "Step 5: Waiting for databases to be ready..."
echo "  Waiting for postgres..."
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=120s
echo "  Waiting for mongodb..."
kubectl wait --for=condition=ready pod -l app=mongodb -n ecommerce --timeout=120s
echo ""

echo "Step 6: Deploying microservices..."
kubectl apply -f user-service/user-service-deployment.yaml
kubectl apply -f user-service/user-service-service.yaml
kubectl apply -f product-service/product-service-deployment.yaml
kubectl apply -f product-service/product-service-service.yaml
kubectl apply -f order-service/order-service-deployment.yaml
kubectl apply -f order-service/order-service-service.yaml
echo ""

echo "Step 7: Waiting for services to be ready..."
echo "  Waiting for user-service..."
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce --timeout=120s
echo "  Waiting for product-service..."
kubectl wait --for=condition=ready pod -l app=product-service -n ecommerce --timeout=120s
echo "  Waiting for order-service..."
kubectl wait --for=condition=ready pod -l app=order-service -n ecommerce --timeout=120s
echo ""

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Current Status:"
kubectl get all -n ecommerce
echo ""
echo "To access services locally:"
echo "  minikube service user-service -n ecommerce"
echo "  minikube service product-service -n ecommerce"
echo "  minikube service order-service -n ecommerce"
echo ""
echo "Or use port-forwarding:"
echo "  kubectl port-forward -n ecommerce svc/user-service 5000:5000"
echo "  kubectl port-forward -n ecommerce svc/product-service 5001:5001"
echo "  kubectl port-forward -n ecommerce svc/order-service 5002:5002"
