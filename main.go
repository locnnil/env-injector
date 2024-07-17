package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
)

func check_env_vars(tests []string) {
	for _, env := range tests {
		if v, ok := os.LookupEnv(env); ok {
			fmt.Printf("Found %s : %s\n", env, v)
			continue
		}
		fmt.Printf("Environment variable %s not set\n", env)
	}
}

func main() {
	var tests = []string{
		"PORT",
		"SERVER",
		"COFFE",
		"CHECK",
	}

	var envfile = []string{
		"ORACULAR",
		"NOBLE",
		"MANTIC",
		"LUNAR",
		"KINETIC",
		"JAMMY",
	}

	fmt.Printf("\nChecking for env variables:\n")
	check_env_vars(tests)

	fmt.Printf("\nChecking for ENVFILE variables:\n")
	check_env_vars(envfile)

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	<-sigs
}
