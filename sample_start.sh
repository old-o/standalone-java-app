#!/bin/bash

# name of application (used in log file names)
app_name=my-app

# the main class (for start-up of Java process)
main_class=net.doepner.sample.Main

script="$(readlink -f ""$0"")"
dir="$(dirname ""$script"")"

pkill -f "$app_name"

source "$dir/.start.sh" "$@"