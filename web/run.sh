#!/bin/bash
source /home/omero/workspace/OMERO-web/omero-virtualenv/bin/activate; /home/omero/workspace/OMERO-web/OMERO.web/bin/omero web start --foreground &
/tmp/jenkins-slave.sh

