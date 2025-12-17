FROM jenkins/jenkins:lts-jdk21
LABEL org.opencontainers.image.authors="OME"

# Temp fix robot test results
ENV JAVA_OPTS "-Dhudson.model.DirectoryBrowserSupport.CSP=" -Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

USER jenkins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER root
RUN chown -R jenkins:jenkins /var/jenkins_home
VOLUME /var/jenkins_home
