#!/bin/bash

/tmp/jenkins-slave.sh

source /home/omero/omero-virtualenv/bin/activate
/home/omero/OMERO.server/bin/omero web start --foreground
