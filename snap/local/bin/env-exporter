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

strip_nested_json_keys() {
  local json="$1"

  # Pull out the contents between the outermost braces
  local body="${json#*\{}"
  body="${body%\}*}"

  local len=${#body} # count of characters in body
  local depth=0 # depth tracks how many object braces are open
  local buf=""
  local segments=() # array to hold segments (key:value pairs)
  local inquotation=0 # flag to track if we are inside a string

  # Segmentation loop:
  # iterate through each character in the body
  # and build segments from the top level of the JSON object
  for ((i=0; i<len; i++)); do
    local c="${body:i:1}" # get one character

    # If we encounter a quotation mark, toggle the inquotation flag
    if [[ "$c" == '"' ]]; then
      if (( inquotation == 0)); then
        inquotation=1
      else 
        inquotation=0
      fi
    fi

    # If inside quotations, just add the character to the buffer and continue
    if (( inquotation == 1 )); then
      buf+="$c"
      continue
    fi

    case "$c" in
      '{') depth=$((depth+1)); buf+="$c" ;;
      '}') depth=$((depth-1)); buf+="$c" ;;
      ',')
        # If depth is 0, then we have a top-level segment
        if (( depth == 0 )); then
          segments+=("$buf")
          buf=""
        else
          buf+="$c"
        fi
        ;;
      *) buf+="$c" ;;
    esac

  done
  # add last buffer
  [[ -n "$buf" ]] && segments+=("$buf")

  # Filter loop:
  # keep only those segments whose value does NOT start with { or [
  local out_segs=()
  for seg in "${segments[@]}"; do
    # trim leading/trailing whitespace
    seg="${seg#"${seg%%[![:space:]]*}"}"
    seg="${seg%"${seg##*[![:space:]]}"}"
    # split at first colon
    local val="${seg#*:}"
    val="${val#"${val%%[![:space:]]*}"}"
    # if value doesn't begin with { or [, keep it
    if [[ ! "$val" =~ ^[\{\[] ]]; then
      out_segs+=("$seg")
    fi
  done

  # Reconstruction loop:
  # Reconstruct an inline JSON object
  local out="{"
  local sep=""
  for seg in "${out_segs[@]}"; do
    out+="${sep}${seg}"
    sep=", "
  done
  out+="}"

  echo "$out"
}

is_nested_json() {
  local json_input="$1"
  local nested_json_pattern='^\{.*\{.*\}.*\}.*$'

  if [[ $json_input =~ $nested_json_pattern ]]; then
    return 0
  else
    return 1
  fi
}

catch_nested_json() {
  local json_input="$1"
  echo "$json_input" | grep -oE '"[^"]*"\s*:\s*\{[^}]*\}'
}

json_to_hash_table() {
  local -n hash_table=$1
  shift
  local json_input="$@"

  # Detect and drop nested JSON objects
  # See https://github.com/canonical/snappy-env/issues/7
  if is_nested_json "$json_input"; then
    local nested=$(catch_nested_json "$json_input")
    err "Nested snap options keys aren't supported:\n$nested"
    json_input=$(strip_nested_json_keys "$json_input")
  fi

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

