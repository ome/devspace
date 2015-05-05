FROM jenkins
MAINTAINER OME

VOLUME /var/jenkins_home
COPY config.xml /var/jenkins_home/config.xml
COPY jobs /var/jenkins_home/jobs
USER root
RUN chown -R jenkins:jenkins /var/jenkins_home
USER jenkins
