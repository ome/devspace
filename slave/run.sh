#!/bin/bash

workspace=/home/omero/workspace/OMERO-test-integration
function shut_down() {
    if [ -d "$workspace" ]; then
      $workspace/src/dist/bin/omero admin stop
    fi
}

/tmp/jenkins-slave.sh
if [ -d "$workspace" ]; then

  $workspace/src/dist/bin/omero admin start
  $workspace/src/dist/bin/omero admin diagnostics
fi

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

wait

