package main

import (
	"fmt"
	"os"
)

func check_env_vars(tests []string) {
  for _, env := range tests{
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
  check_env_vars(tests)
  os.Exit(0)
}

