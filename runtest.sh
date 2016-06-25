#!/bin/bash

set -e -u -x


# start docker container
if [[ "darwin" == "${OSTYPE//[0-9.]/}" ]]; then
  EXTRA=docker-compose.osx.yml ./ds up -d
else
  ./ds up -d
fi

# inspect containers
service_containers=( devspace_pg_1 devspace_redis_1 )
selenium_containers=( devspace_seleniumhub_1 devspace_seleniumfirefox_1 devspace_seleniumchrome_1 )
omero_containers=( devspace_omero_1 devspace_web_1 devspace_nginx_1 devspace_testintegration_1 )
all_containers=( "${service_containers[@]}" "${selenium_containers[@]}" "${omero_containers[@]}" )

for cname in "${all_containers[@]}"
do
   :
   docker inspect -f {{.State.Running}} $cname
done

# check if Jenkins is fully up and running
d=10
while ! docker logs devspace_jenkins_1 2>&1 | grep "Jenkins is fully up and running"
do sleep 10
  d=$[$d -1]
  if [ $d -lt 0 ]; then
    docker logs devspace_jenkins_1
    exit 1
  fi
done

# check if devspace_slaves_1 is running and conected to jenkins
for cname in "${omero_containers[@]}"
do
   :
   SLAVE_ADDR=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $cname`
   echo "Checking $cname $SLAVE_ADDR is connected to jenkins"
   d=10
   while ! docker logs devspace_jenkins_1 2>&1 | grep "from /${SLAVE_ADDR}"
   do sleep 10
     d=$[$d -1]
     if [ $d -lt 0 ]; then
       docker logs devspace_jenkins_1
       docker logs $cname
       exit 1
     fi
   done
done


curl -k -I https://localhost:8443

STATUS=`curl -k --write-out %{http_code} --silent --output /dev/null https://localhost:8443`

if [ ! "200" == "$STATUS" ]; then
    exit 1
fi

# CLEANUP
./ds stop
./ds rm -f
