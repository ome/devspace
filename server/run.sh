#!/bin/bash
/tmp/jenkins-slave.sh

source /tmp/omero-install/settings.env
sudo chown omero "$OMERO_DATA_DIR"

/home/omero/OMERO.server/bin/omero admin start