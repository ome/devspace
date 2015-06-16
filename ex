#!/bin/bash

set -u
set -e

SPACE=$(basename $(pwd) | tr -d '.')
NAME=${NAME:-$SPACE}
WHICH=$1
shift

if [[ -t 0 ]]; then
    FLAGS=-ti
else
    FLAGS=-i
fi

exec docker exec $FLAGS "$NAME"_"$WHICH"_1 bash "$@"
