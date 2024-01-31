#!/bin/bash

workspace=/home/omero/workspace/OMERO-server
function shut_down() {
    if [ -d "$workspace" ]; then
      $workspace/OMERO.server/bin/omero admin stop
    fi
}

/tmp/jenkins-slave.sh
if [ -d "$workspace" ]; then
  $workspace/OMERO.server/bin/omero admin start
  $workspace/OMERO.server/bin/omero admin diagnostics
fi

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

wait
