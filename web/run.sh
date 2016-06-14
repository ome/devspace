#!/bin/bash

workspace=/home/omero/workspace/OMERO-web
djangopid="$workspace/OMERO.web/var/django.pid"
if [ -f $djangopid ]; then
    rm -f $djangopid
fi

if [ -d "$workspace" ]; then
    source $workspace/omero-virtualenv/bin/activate; $workspace/OMERO.web/bin/omero web start --foreground &
fi

/tmp/jenkins-slave.sh
