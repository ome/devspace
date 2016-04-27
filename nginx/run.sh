#!/bin/bash
sudo chmod 777 -R /home/omero/static/

function shut_down() {
    sudo nginx -c stop
}

/tmp/jenkins-slave.sh &
sudo nginx &

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

wait
