# ecommerce-microservices-demo

A DevOps learning project demonstrating containerization with Docker and orchestration with Kubernetes. This project builds a complete microservices architecture for an e-commerce system, progressing from local development to production-ready Kubernetes deployment. It is important to notice that this project is just a theorical concept demonstration and is not to be used on a production environment.

## Project Goal

Learn and show DevOps engineering fundamentals by building, containerizing, and orchestrating 3 microservices with monitoring and logging, making use of enterprise level technologies.
This project envolves 4 stages:
- Stage 1: Building and containerizing microservices
- Stage 2: Kubernetes fundamentals and local deployment
- Stage 3: Monitoring with Prometheus and Grafana
- Stage 4: Centralized logging and production readiness

## Architecture

The system consists of three independent microservices, each with its own database:
```
User Service (Flask)          ──┐
Order Service (Go)            ──┼──> PostgreSQL
                               ┘

Product Service (Node.js)     ──> MongoDB
```

### Microservices

**User Service** (Python Flask)
- Manages user accounts and profiles
- Endpoints: GET /users, POST /users, GET /users/{id}, GET /health
- Database: PostgreSQL
- Port: 5000

**Product Service** (Node.js Express)
- Manages products and inventory
- Endpoints: GET /products, POST /products, GET /products/{id}, GET /health
- Database: MongoDB
- Port: 5001

**Order Service** (Go)
- Processes orders and order history
- Endpoints: GET /orders, POST /orders, GET /orders/{id}, GET /health
- Database: PostgreSQL
- Port: 5002

## Project Structure
```
ecommerce-microservices-demo/
├── docker-compose.yaml           # Local development with all services
├── README.md                      # This file
│
├── user-service/                 # Flask microservice
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
│
├── product-service/              # Node.js microservice
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
│
├── order-service/                # Go microservice
│   ├── Dockerfile
│   ├── main.go
│   └── go.mod
│
├── kubernetes/                   # Kubernetes manifests (Stage 2)
│   ├── namespaces.yaml
│   ├── user-service/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── product-service/
│   ├── order-service/
│   ├── databases/
│   │   ├── postgres.yaml
│   │   └── mongodb.yaml
│   └── monitoring/               # Prometheus & Grafana (Stage 3)
│       ├── prometheus.yaml
│       └── grafana.yaml
│
└── helm/                         # Helm chart for deployment (Stage 4)
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

## Getting Started

### Prerequisites

- WSL2 with Ubuntu 22.04 (Windows) or Linux/Mac
- Docker Desktop (with WSL2 integration for Windows)
- docker-compose
- Git

### Local Development (Stage 1)

1. **Clone the repository:**
```bash
   git clone <repo-url>
   cd ecommerce-microservices-demo
```

2. **Start all services:**
```bash
   docker-compose up
```

   This will:
   - Build the three microservice images
   - Start PostgreSQL and MongoDB containers
   - Start all three microservices
   - Mount source code as volumes for live editing

3. **Verify services are running:**
```bash
   curl http://localhost:5000/health  # User Service
   curl http://localhost:5001/health  # Product Service
   curl http://localhost:5002/health  # Order Service
```

4. **Test the APIs:**
```bash
   # Create a user
   curl -X POST http://localhost:5000/users \
     -H "Content-Type: application/json" \
     -d '{"name":"John Doe","email":"john@example.com"}'

   # Get all users
   curl http://localhost:5000/users
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f user-service

# Specific service with last 100 lines
docker-compose logs --tail=100 user-service
```

### Stop Services
```bash
docker-compose down
```

## Database Access

### PostgreSQL
```bash
# Connect to PostgreSQL container
docker exec -it <postgres-container-id> psql -U postgres -d users_db

# View users table
SELECT * FROM user;
# View orders table
SELECT * FROM "order";
```

### MongoDB
```bash
# Connect to MongoDB container
docker exec -it <mongodb-container-id> mongosh

# View databases and collections
show databases
use products_db
db.products.find()
```

## Stage 2: Kubernetes Deployment

Deploy to local Kubernetes cluster:
```bash
# Create namespace
kubectl apply -f kubernetes/namespaces.yaml

# Deploy databases
kubectl apply -f kubernetes/databases/

# Deploy microservices
kubectl apply -f kubernetes/user-service/
kubectl apply -f kubernetes/product-service/
kubectl apply -f kubernetes/order-service/
```

## Stage 3: Monitoring

Prometheus and Grafana dashboards track:
- Request rates and latencies
- Error rates
- Container resource usage
- Database query performance

Access Grafana at `http://localhost:3000`

## Stage 4: Helm Deployment

Package entire application with Helm:
```bash
helm install ecommerce ./helm
```

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Flask SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/)
- [Express.js](https://expressjs.com/)
- [Go Web Development](https://golang.org/doc/articles/wiki/)

## Learning Outcomes

After completing this project, you'll understand:
- Containerizing applications with Docker best practices
- Multi-container orchestration with Docker Compose
- Kubernetes fundamentals (Pods, Deployments, Services)
- Persistent storage in containers
- Microservices communication
- Monitoring containerized applications
- Deploying to production with Kubernetes
- Infrastructure as Code with Helm

## Author

Kenneth Palacios

## License

MIT