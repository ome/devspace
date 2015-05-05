#!/bin/bash
SPACE=$(basename $(pwd))
NAME=${NAME:-$SPACE}
exec docker exec -ti "$NAME"_"$1"_1 bash
