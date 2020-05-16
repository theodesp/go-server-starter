package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/rs/zerolog"
)

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	host := getHostname()
	log := zerolog.New(os.Stdout).With().
		Timestamp().
		Str("role", "go-requestbin-server").
		Str("host", host).
		Logger().
		Output(zerolog.ConsoleWriter{Out: os.Stderr})

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
	idleConnsClosed := make(chan struct{})
	go func() {
		sigint := make(chan os.Signal, 1)
		signal.Notify(sigint, os.Interrupt)
		<-sigint

		// We received an interrupt signal, shut down.
		if err := server.Shutdown(context.Background()); err != nil {
			// Error from closing listeners, or context timeout:
			log.Error().Err(err).Msg("HTTP server Shutdown")

		}
		close(idleConnsClosed)
	}()
	log.Info().Msg("Listening...")
	if err := server.ListenAndServe(); err != http.ErrServerClosed {
		// Error starting or closing listener:
		log.Fatal().Err(err).Msg("HTTP server ListenAndServe")
	}

	<-idleConnsClosed
}

func getHostname() string {
	host, err := os.Hostname()
	if err != nil {
		return ""
	}
	return host
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}
