#!/bin/bash
/home/omero/workspace/OMERO-server/OMERO.server/bin/omero admin start --foreground &
/tmp/jenkins-slave.sh
