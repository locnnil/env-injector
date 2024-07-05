package main

import (
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

func getEnvVariables() map[string]string {
	envVars := make(map[string]string)
	for _, env := range os.Environ() {
		fmt.Printf("\nenv: %v\n", env)
		pair := strings.SplitN(env, "=", 2)
		if len(pair) == 2 {
			fmt.Printf("key: %v , value: %v\n", pair[0], pair[1])
			envVars[pair[0]] = pair[1]
		}
	}
	return envVars
}

func checkForNewEnvVariables(initialEnvVars map[string]string) {
	for {
		currentEnvVars := getEnvVariables()
		for key, value := range currentEnvVars {
			if _, exists := initialEnvVars[key]; !exists {
				fmt.Printf("Environment variable detected: %s=%s\n", key, value)
				initialEnvVars[key] = value
			}
		}
		time.Sleep(10 * time.Second)
		select {}
	}
}

func main() {
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		sig := <-sigChan

		fmt.Printf("Signal received: %v\n", sig)
		fmt.Printf("Exiting...\n")
		os.Exit(0)
	}()

	initialEnvVars := getEnvVariables()
	fmt.Println("Initial environment variables captured. Monitoring for new variables...")

	checkForNewEnvVariables(initialEnvVars)
}
