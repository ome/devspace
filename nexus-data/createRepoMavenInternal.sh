#!/bin/sh

# Based on
# https://github.com/sonatype-nexus-community/nexus-scripting-examples/tree/master/simple-shell-example
set -eux
NEXUS=http://localhost:8081/nexus
curl -f -u admin:admin123 --header "Content-Type: application/json" "$NEXUS/service/rest/v1/script/" -d @/nexus-data/createRepoMavenInternal.json
curl -X POST -u admin:admin123 --header "Content-Type: text/plain" "$NEXUS/service/rest/v1/script/createRepoMavenInternal/run"

