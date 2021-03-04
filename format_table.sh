#! /bin/bash

# arg empty check
test -n "$1" -a -n "$2" || exit 1 

awk 'NR=='"$1"',NR=='"$2"'{print $0}' | sed 's/\s\s*/,/g' | column -t -s,
