#!/bin/bash
sudo chmod 777 -R /home/omero/static/
sudo nginx &
/tmp/jenkins-slave.sh