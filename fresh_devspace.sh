#!/usr/bin/env bash
set -e
set -u
set -x
set -o pipefail

SOURCE=$1
TOPIC=$2

# Check in devspace checkout >= 0.11
test -e pipeline-configs.yaml

# Check that we have scc on the path
which scc

# Check that necessary files are present (TODO: generate them)
test -e slave/.ssh || cp -nr $SOURCE/.ssh slave/
test -e slave/.gitconfig || cp -nr $SOURCE/.gitconfig slave/

# Perform configuration
HOST_IP=$(hostname -I | cut -f1 -d" ")
./sslcert jenkins/sslcert $HOST_IP
./sslcert nginx/sslcert $HOST_IP
python ./rename.py $TOPIC

PASSWORD=$(openssl rand -hex 32)
sed -i "s/JENKINS_PASSWORD=devspace/JENKINS_PASSWORD=$PASSWORD/" .env

git commit -a -m "Local changes for $TOPIC"

echo PASSWORD: $PASSWORD
