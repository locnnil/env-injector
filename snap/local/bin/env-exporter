#!/bin/bash

debug() {
  [ "$DEBUG" != "true" ] && return
  echo -e "[DEBUG] $1"
}

err() {
  echo -e "\n[ERROR] $1\n"
}

debug_hash_table() {
  [ "$DEBUG" != "true" ] && return
  local -n table="$1"
  debug "Hash table:\n"
  for key in "${!table[@]}"; do
    debug "$key : ${table[$key]}\n"
  done
}

json_to_hash_table() {
  local -n hash_table=$1
  shift
  local json_input="$@"

  json_input=$(echo "$json_input" | sed 's/[{}]//g' | tr -d '[:space:]')

  IFS=',' read -ra kv_pairs <<<"$json_input"

  for pair in "${kv_pairs[@]}"; do
    IFS=':' read -r key value <<<"$pair"

    key=$(echo "$key" | sed 's/"//g')
    value=$(echo "$value" | sed 's/"//g')

    hash_table["$key"]="$value"
  done
}

check_num_at_start() {
  if [[ "$1" =~ ^[0-9]+ ]]; then
    err "Environment variable name shouldn't begin with a number: $1"
    return 1
  fi
  return 0
}

convert_keys() {
  local old=$1
  local -n new=$2

  check_num_at_start $old
  [ $? -ne 0 ] && return 1

  new=$(echo "$old" | tr '[:lower:]' '[:upper:]')
  new=$(echo "$new" | tr '-' '_')

  debug "old: $old -> new: $new"
}

export_vars() {
  declare -n table=$1
  local nk
  for key in "${!table[@]}"; do

    convert_keys $key nk
    [ $? -ne 0 ] && continue

    export "$nk=${table[$key]}"
  done
}

handle_envs() {
  json_str="$@"
  [ -z "$json_str" ] && return

  debug "snapctl json:\n$json_str"

  declare -A vars_table
  json_to_hash_table vars_table $json_str
  debug_hash_table vars_table

  export_vars vars_table
}

handle_envfile() {
  local envfile=$1
  [ -z "$envfile" ] && return

  debug "Environment file path: $envfile"

  if [ ! -f "$envfile" ]; then
    err "Environment file not found: $envfile"
    return 1
  fi

  if [ ! -r "$envfile" ]; then
    err "Environment file not readable: $envfile"
    return 1
  fi

  set -a
  source "$envfile"
  set +a
}

main() {
  DEBUG=$(snapctl get env-injector.debug)
  debug "debug : $debug"

  local app
  if [ -n $env_alias ]; then
    app=$env_alias
  else
    app=$(basename $1) || exit 0
  fi
  debug "App alias: $app"

  debug "Checking for GLOBAL envfile..."
  envfile=$(snapctl get envfile)
  handle_envfile $envfile

  debug "Checking for LOCAL envfile..."
  envfile=$(snapctl get apps.$app.envfile)
  handle_envfile $envfile

  debug "Checking for GLOBAL env variables..."
  json_str=$(snapctl get env)
  handle_envs $json_str

  debug "Checking for LOCAL env variables..."
  json_str=$(snapctl get apps.$app.env)
  handle_envs $json_str
}

main $1

exec "$@"
