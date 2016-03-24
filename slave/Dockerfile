FROM openmicroscopy/omero-build-c6-multienv

MAINTAINER OME

ENV JENKINS_SWARM_VERSION 2.0
ENV LANG en_US.UTF-8

RUN yum install -y http://download-aws.ej-technologies.com/exe4j/exe4j_linux_5_0_1.rpm

RUN adduser -u 1000 slave
USER slave
WORKDIR /tmp
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

COPY jenkins-slave.sh /tmp/jenkins-slave.sh
ENTRYPOINT ["/tmp/jenkins-slave.sh"]
