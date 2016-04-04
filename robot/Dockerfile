FROM openmicroscopy/omero-ssh-systemd

MAINTAINER OME

ENV JENKINS_SWARM_VERSION 2.0
ENV LANG en_US.UTF-8
ARG JAVAVER=openjdk18

# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

RUN yum install -y initscripts \
    && yum clean all

# Download and run omero-install.
ENV OMERO_INSTALL /tmp/omero-install/linux

RUN yum install -y git \
    && git clone -b java-parameters https://github.com/jburel/omero-install.git /tmp/omero-install \
    && yum clean all

# Customize: run particular scripts from omero-install
RUN bash $OMERO_INSTALL/step01_centos7_init.sh
RUN bash $OMERO_INSTALL/step01_centos_java_deps.sh
RUN bash $OMERO_INSTALL/step01_centos7_ice_deps.sh

RUN yum install -y python python-pip \
    && yum clean all
RUN pip install robotframework
RUN pip install robotframework-selenium2library

VOLUME ["/home/omero/tests"]

WORKDIR /home/omero

RUN yum install -y http://download-aws.ej-technologies.com/exe4j/exe4j_linux_5_0_1.rpm && yum clean all

USER omero
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

USER root

ADD ./jenkins-slave.sh /tmp/jenkins-slave.sh
RUN chmod +x /tmp/jenkins-slave.sh
ADD ./jenkins.service /etc/systemd/system/jenkins.service
RUN systemctl enable jenkins.service

RUN yum install -y unzip \
    && yum clean all

#ENTRYPOINT ["/tmp/jenkins-slave.sh"]
