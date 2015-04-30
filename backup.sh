# http://www.kf-interactive.com/blog/roll-your-own-docker-registry-with-docker-compose-supervisor-and-nginx/
docker run -ti --volumes-from=dockerregistry_storage_1 -v $(pwd)/backup:/backup kfinteractive/backup-tools rsync -avz /var/lib/docker/registry/ /backup/
docker cp jenkins-dv:/var/jenkins_home /tmp/jenkins-backup
