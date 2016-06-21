package main

import (
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s hostname:port\n", os.Args[0])
		os.Exit(1)
	}
	iface := os.Args[1]
	router := gin.Default()
	router.Static("/", "./public")

	router.Run(iface)
}
