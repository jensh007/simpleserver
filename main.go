package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
}

func main() {
	http.HandleFunc("/", hello)
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/helloworld", hello)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server running on port: %s \n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}
