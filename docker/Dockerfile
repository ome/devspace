FROM openmicroscopy/devslave-c7:0.7.2

MAINTAINER OME

# manually install java11
RUN yum -y install java-11-openjdk-devel
# Switch Java version
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN yum -y install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

RUN yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

RUN yum -y install docker-ce

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

COPY run.sh /tmp/run.sh
RUN chmod a+x /tmp/run.sh
USER omero
CMD ["/tmp/run.sh"]
