#!/bin/bash
sudo chmod 777 -R /home/omero/static/

/tmp/jenkins-slave.sh &
sudo nginx -g "daemon off;"