FROM ubuntu:12.04

MAINTAINER OME

ENV JENKINS_SWARM_VERSION 1.24
ENV LANG en_US.UTF-8

RUN adduser -u 11521 slave
RUN apt-get update && apt-get install -y curl

USER slave
WORKDIR /tmp
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

COPY jenkins-slave.sh /tmp/jenkins-slave.sh
ENTRYPOINT ["/tmp/jenkins-slave.sh"]
