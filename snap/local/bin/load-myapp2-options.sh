#!/bin/bash

debug="$(snapctl get debug)"
if [ -z "$debug" ]; then
  export DEBUG="$debug"
fi

port="$(snapctl get myapp2.port)"
if [ -z "$port" ]; then
  export PORT="$port"
fi

addr="$(snapctl get myapp2.bind-address)"
if [ -z "$addr" ]; then
  export BIND_ADDRESS="$addr"
fi

# < ... > 

exec "$@"
