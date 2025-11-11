FROM golang:1.18-alpine AS builder

WORKDIR /app

COPY go.mod main.go ./

RUN go get github.com/gin-gonic/gin@v1.9.1 && \
    go get gorm.io/driver/postgres@v1.5.2 && \
    go get gorm.io/gorm@v1.25.2

RUN CGO_ENABLED=0 GOOS=linux go build -o order-service main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/order-service .

EXPOSE 5002
CMD ["./order-service"]