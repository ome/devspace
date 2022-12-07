FROM jenkins/jenkins:lts
MAINTAINER OME

# Temp fix robot test results
ENV JAVA_OPTS "-Dhudson.model.DirectoryBrowserSupport.CSP=" -Djenkins.install.runSetupWizard=false

COPY install-plugins.sh usr/local/bin/
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

USER root
RUN chown -R jenkins:jenkins /var/jenkins_home
VOLUME /var/jenkins_home
