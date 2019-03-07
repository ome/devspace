#!/bin/bash

set -eu
set -x

# Adjust docker permissions
# https://github.com/jenkinsci/docker/issues/263#issuecomment-217955379
sudo groupmod -g $(stat -c %g /var/run/docker.sock) docker
sudo usermod -aG docker omero

exec sudo -iu omero env SLAVE_PARAMS="$SLAVE_PARAMS" SLAVE_EXECUTORS="$SLAVE_EXECUTORS" SLAVE_NAME="$SLAVE_NAME" JENKINS_MASTER="$JENKINS_MASTER" /tmp/jenkins-slave.sh
