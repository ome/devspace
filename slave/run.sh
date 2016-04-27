#!/bin/bash

function shut_down() {
    /home/omero/workspace/OMERO-test-integration/src/dist/bin/omero admin stop
}

/tmp/jenkins-slave.sh &
/home/omero/workspace/OMERO-test-integration/src/dist/bin/omero admin start

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

wait

