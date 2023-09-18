FROM jburel/devslave-c7:0.8.3

MAINTAINER OME

USER root


RUN dnf -y install -y yum-utils \
  device-mapper-persistent-data \
  lvm2


RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

RUN dnf -y install docker-ce

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

COPY run.sh /tmp/run.sh
RUN chmod a+x /tmp/run.sh
USER omero
CMD ["/tmp/run.sh"]
