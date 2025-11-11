package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Order struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	UserID    uint   `json:"user_id"`
	ProductID uint   `json:"product_id"`
	Quantity  int    `json:"quantity"`
	Status    string `json:"status"`
}

var db *gorm.DB

func init() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=localhost user=postgres password=TVuOVT9uJw dbname=users_db port=5432 sslmode=disable"
	}

	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	db.AutoMigrate(&Order{})
}

func main() {
	router := gin.Default()

	router.GET("/health", healthHandler)
	router.GET("/orders", getOrdersHandler)
	router.POST("/orders", createOrderHandler)
	router.GET("/orders/:id", getOrderHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "5002"
	}

	log.Printf("Order service listening on port %s", port)
	router.Run(":" + port)
}

func healthHandler(c *gin.Context) {
	c.JSON(200, gin.H{"status": "healthy"})
}

func getOrdersHandler(c *gin.Context) {
	var orders []Order
	db.Find(&orders)
	c.JSON(200, orders)
}

func createOrderHandler(c *gin.Context) {
	var order Order
	if err := c.ShouldBindJSON(&order); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	order.Status = "pending"
	db.Create(&order)
	c.JSON(201, order)
}

func getOrderHandler(c *gin.Context) {
	id := c.Param("id")
	var order Order

	if err := db.First(&order, id).Error; err != nil {
		c.JSON(404, gin.H{"error": "Order not found"})
		return
	}

	c.JSON(200, order)
}