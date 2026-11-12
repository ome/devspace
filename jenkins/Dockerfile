FROM jenkins/jenkins:lts-jdk21

USER root
RUN apt-get update \
    && apt-get install -y --only-upgrade ca-certificates \
    && dpkg-query -W -f='${Version}\n' ca-certificates \
    && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.authors="OME"

# Temp fix robot test results
ENV JAVA_OPTS "-Dhudson.model.DirectoryBrowserSupport.CSP=" -Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

USER jenkins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER root
RUN chown -R jenkins:jenkins /var/jenkins_home
VOLUME /var/jenkins_home
