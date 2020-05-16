package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	mux := http.NewServeMux()
	hs := http.HandlerFunc(HelloServer)
	mux.Handle("/", hs)

	server := &http.Server{
		ReadHeaderTimeout: 20 * time.Second,
		ReadTimeout:       1 * time.Minute,
		WriteTimeout:      2 * time.Minute,
		Handler:           mux,
		Addr:              ":3000",
	}
	log.Println("Listening...")
	server.ListenAndServe()
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}
