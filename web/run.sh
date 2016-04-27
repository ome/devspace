#!/bin/bash

djangopid=/home/omero/workspace/OMERO-web/OMERO.web/var/django.pid
if [ -f $djangopid ]; then
    rm -f $djangopid
fi

function shut_down() {
    source /home/omero/workspace/OMERO-web/omero-virtualenv/bin/activate; /home/omero/workspace/OMERO-web/OMERO.web/bin/omero web stop
}

/tmp/jenkins-slave.sh &
source /home/omero/workspace/OMERO-web/omero-virtualenv/bin/activate; /home/omero/workspace/OMERO-web/OMERO.web/bin/omero web start

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

wait