# Kubernetes Deployment

Production-ready Kubernetes manifests for deploying the e-commerce microservices platform.

## Architecture

This deployment consists of three microservices and two databases:

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  user-service   │     │ product-service  │     │  order-service  │
│   (Flask/5000)  │     │  (Node.js/5001)  │     │    (Go/5002)    │
└────────┬────────┘     └─────────┬────────┘     └────────┬────────┘
         │                        │                       │
         ▼                        ▼                       │
  ┌─────────────┐          ┌─────────────┐              │
  │  PostgreSQL │          │   MongoDB   │              │
  │   (5432)    │          │   (27017)   │              │
  └─────────────┘          └─────────────┘              │
         ▲                                               │
         └───────────────────────────────────────────────┘
```

## Prerequisites

- Kubernetes cluster (Minikube, Kind, or cloud provider)
- kubectl CLI tool installed
- Docker images pushed to registry:
  - `kpalaciosm02/user-service:v1.0.0`
  - `kpalaciosm02/product-service:v1.0.0`
  - `kpalaciosm02/order-service:v1.0.0`

## Quick Start

### Deploy Everything

```bash
cd kubernetes
./deploy.sh
```

This script will:
1. Create the `ecommerce` namespace
2. Create secrets for database credentials
3. Provision persistent storage (PVCs)
4. Deploy PostgreSQL and MongoDB
5. Deploy all three microservices
6. Wait for all pods to be ready

**Expected output:**
```
========================================
Deployment Complete!
========================================

Current Status:
NAME                              READY   STATUS    RESTARTS   AGE
pod/mongodb-xxx                   1/1     Running   0          2m
pod/postgres-xxx                  1/1     Running   0          2m
pod/user-service-xxx              1/1     Running   0          1m
pod/product-service-xxx           1/1     Running   0          1m
pod/order-service-xxx             1/1     Running   0          1m
```

### Tear Down

```bash
cd kubernetes
./destroy.sh
```

**Warning:** This deletes all data including databases!

## Directory Structure

```
kubernetes/
├── deploy.sh                    # Automated deployment script
├── destroy.sh                   # Automated teardown script
├── namespace.yaml               # Namespace definition
│
├── postgres/
│   ├── postgres-secret.yaml     # Database credentials (gitignored)
│   ├── postgres-pvc.yaml        # 1Gi persistent storage
│   ├── postgres-deployment.yaml # PostgreSQL v15
│   └── postgres-service.yaml    # ClusterIP service (5432)
│
├── mongo/
│   ├── mongodb-secret.yaml      # Database credentials (gitignored)
│   ├── mongodb-pvc.yaml         # 1Gi persistent storage
│   ├── mongodb-deployment.yaml  # MongoDB v7.0
│   └── mongodb-service.yaml     # ClusterIP service (27017)
│
├── user-service/
│   ├── user-service-deployment.yaml  # 2 replicas, health checks
│   └── user-service-service.yaml     # ClusterIP service (5000)
│
├── product-service/
│   ├── product-service-deployment.yaml  # 2 replicas, health checks
│   └── product-service-service.yaml     # ClusterIP service (5001)
│
└── order-service/
    ├── order-service-deployment.yaml  # 2 replicas, health checks
    └── order-service-service.yaml     # ClusterIP service (5002)
```

## Key Features

### High Availability
- All microservices run with 2 replicas
- Automatic pod restart on failure
- Rolling updates with zero downtime

### Health Checks
All services implement liveness and readiness probes:
- **Liveness**: Detects crashed pods → automatic restart
- **Readiness**: Prevents traffic to unhealthy pods

### Resource Management
Resource limits prevent resource starvation:
- **Microservices**: 128Mi-256Mi RAM, 0.1-0.2 CPU
- **Databases**: 256Mi-512Mi RAM, 0.25-0.5 CPU

### Security
- Database credentials stored in Kubernetes Secrets
- Secrets not committed to git (see `.gitignore`)
- All services use internal ClusterIP (not exposed publicly)

### Data Persistence
- PostgreSQL: 1Gi persistent volume
- MongoDB: 1Gi persistent volume
- Data survives pod restarts

## Accessing Services

### From Within Cluster
Services are accessible via DNS:
```bash
http://user-service:5000
http://product-service:5001
http://order-service:5002
```

### From Outside Cluster (Development)

**Option 1: Port Forwarding**
```bash
kubectl port-forward -n ecommerce svc/user-service 5000:5000
curl http://localhost:5000/health
```

**Option 2: Minikube Service**
```bash
minikube service user-service -n ecommerce
```

## Manual Deployment

If you prefer to deploy manually:

```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Create secrets (update credentials first!)
kubectl apply -f postgres/postgres-secret.yaml
kubectl apply -f mongo/mongodb-secret.yaml

# 3. Create storage
kubectl apply -f postgres/postgres-pvc.yaml
kubectl apply -f mongo/mongodb-pvc.yaml

# 4. Deploy databases
kubectl apply -f postgres/postgres-deployment.yaml
kubectl apply -f postgres/postgres-service.yaml
kubectl apply -f mongo/mongodb-deployment.yaml
kubectl apply -f mongo/mongodb-service.yaml

# 5. Wait for databases
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=120s
kubectl wait --for=condition=ready pod -l app=mongodb -n ecommerce --timeout=120s

# 6. Deploy microservices
kubectl apply -f user-service/
kubectl apply -f product-service/
kubectl apply -f order-service/
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n ecommerce
kubectl describe pod <pod-name> -n ecommerce
```

### View Logs
```bash
kubectl logs -n ecommerce -l app=user-service --tail=50
kubectl logs -n ecommerce <pod-name> --follow
```

### Check Service Endpoints
```bash
kubectl get endpoints -n ecommerce
```

### Common Issues

**Pods stuck in Pending:**
- Check if PVCs are bound: `kubectl get pvc -n ecommerce`
- Check node resources: `kubectl describe node`

**Pods CrashLoopBackOff:**
- Check logs: `kubectl logs <pod-name> -n ecommerce`
- Verify secrets exist: `kubectl get secrets -n ecommerce`
- Check database connectivity

**Services not accessible:**
- Verify service exists: `kubectl get svc -n ecommerce`
- Check endpoints: `kubectl get endpoints -n ecommerce`
- Test from within cluster: `kubectl run -it --rm debug --image=curlimages/curl -n ecommerce -- sh`

## Production Considerations

This setup is designed for **learning and development**. For production:

1. **Use External Secret Management**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Sealed Secrets

2. **Implement Ingress**
   - Replace ClusterIP with Ingress controller
   - Add TLS/SSL certificates
   - Configure domain routing

3. **Add Monitoring**
   - Prometheus for metrics
   - Grafana for visualization
   - Alert manager for notifications

4. **Implement Autoscaling**
   - Horizontal Pod Autoscaler (HPA)
   - Vertical Pod Autoscaler (VPA)
   - Cluster Autoscaler

5. **Database Best Practices**
   - Use managed databases (RDS, Cloud SQL)
   - Implement backup strategies
   - Use StatefulSets for database clusters

6. **CI/CD Integration**
   - Automate deployments
   - Use GitOps (ArgoCD, Flux)
   - Implement canary deployments

## API Endpoints

### User Service (Port 5000)
- `GET /health` - Health check
- `GET /users` - List all users
- `POST /users` - Create user
- `GET /users/{id}` - Get user by ID

### Product Service (Port 5001)
- `GET /health` - Health check
- `GET /products` - List all products
- `POST /products` - Create product
- `GET /products/{id}` - Get product by ID

### Order Service (Port 5002)
- `GET /health` - Health check
- `GET /orders` - List all orders
- `POST /orders` - Create order
- `GET /orders/{id}` - Get order by ID

## License

MIT
