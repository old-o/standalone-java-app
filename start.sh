#!/bin/bash

# script should exit if any command fails
set -e

function envfail() {
  echo $1;
  echo "Please adjust $setenv_script and retry ..."
  exit 1
}
function fail_if_empty() {
  if [ -z "$1" ]; then
    envfail "Variable \'$2\' is unset or empty."
  fi
}
function fail_if_whitespace_in() {
  if [[ "$1" =~ .*[[:space:]].* ]]; then
    envfail "Value of \'$2\' contains whitespace: $1 "
  fi
}
function fail_if_empty_or_whitespace_in() {
    fail_if_empty "$1" "$2"
    fail_if_whitespace_in "$1" "$2"
}

script=$(readlink -f "$0")
fail_if_whitespace_in "$script" "Script path"

# ok, now we know $script contains no spaces so
# we don't need quoting acrobatics from here on

dir="$(dirname $script)"
parent="$(dirname $dir)"
setenv_script="$parent/setenv.sh"

if [ ! -e "$setenv_script" ]; then
  echo "$setenv_script not found"
  cp "$dir/.setenv.sh" "$setenv_script"
  envfail "Created a default $setenv_script for you."
fi
setenv_script_file="$(readlink -f $setenv_script)"
if [ -r "$setenv_script_file" ]; then
  echo "Sourcing $setenv_script"
  source "$setenv_script"
else
  envfail "Cannot read $setenv_script"
fi

fail_if_empty_or_whitespace_in "$env" 'env'
config="$(readlink -f ""$dir/config"")"
if [[ ! -r "$config" || ! -d "$config" ]]; then
  envfail "Cannot read directory $config"
fi
config_env="$config/$env"
if [[ ! -r "$config_env" || ! -d "$config_env" ]]; then
  envfail "Invalid env=$env : Cannot read directory $config_env"
fi

fail_if_empty_or_whitespace_in "$java_home" 'java_home'
java="$java_home/bin/java"
if [ ! -e "$java" ]; then
  envfail "$java is not an executable file"
fi
java_version=$("$java" -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f2)
if [ $java_version -lt "7" ]; then
  envfail "Java 1.7 or higher is required."
fi

fail_if_empty_or_whitespace_in "$app_name" 'app_name'
log_name_prefix="${app_name}_${env}_"

fail_if_empty_or_whitespace_in "$main_class" 'main_class'

# turn on bash debug output for the following lines
set -x

log_dir="$parent/log"
mkdir -p "$log_dir"

nohup \
"$java" -DlogDir="$log_dir" \
        -DlogNamePrefix="$log_name_prefix" \
        -cp "$config_env:$config:$dir/lib/*" \
        "$main_class" \
        $@ \
        > "${log_dir}/${log_name_prefix}_stdout.log" 2>&1 &
