#!/bin/bash
rm -rf /home/omero/workspace/OMERO-web/OMERO.web/django.pid
source /home/omero/workspace/OMERO-web/omero-virtualenv/bin/activate; /home/omero/workspace/OMERO-web/OMERO.web/bin/omero web start &
/tmp/jenkins-slave.sh
