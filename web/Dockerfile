FROM openmicroscopy/omero-ssh-systemd
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

# OMERO.py prerequesties
RUN yum install -y epel-release && \
    yum clean all

RUN yum install -y unzip && \
    yum clean all

RUN yum install -y \
    python-pip python-devel python-virtualenv \
    numpy scipy python-matplotlib python-tables && \
    yum clean all
  
RUN curl -o /etc/yum.repos.d/zeroc-ice-el7.repo \
    http://download.zeroc.com/Ice/3.5/el7/zeroc-ice-el7.repo

RUN yum install -y ice ice-python ice-servers && \
    yum clean all

# install Pillow via pip
RUN yum install -y \
    zlib-devel \
    libjpeg-devel \
    gcc && \
    yum clean all

RUN yum install -y nginx && \
    yum clean all

RUN sed -i.bak -re 's/( default_server.*)/; #\1/' /etc/nginx/nginx.conf
ADD ./omeroweb.sh /home/omero/omeroweb.sh
RUN chown omero:omero /home/omero/omeroweb.sh
RUN chmod +x /home/omero/omeroweb.sh
RUN chmod a+X /home/omero

EXPOSE 80

# Josh / late addition
RUN yum -y install java-1.8.0-openjdk
RUN usermod -u 11521 omero
# Ola new commit
ADD ./omeroweb.service /etc/systemd/system/omeroweb.service
RUN ln -s /etc/systemd/system/omeroweb.service /etc/systemd/system/multi-user.target.wants/omeroweb.service


# AS OMERO user
USER omero
ENV HOME /home/omero
WORKDIR /home/omero

#
# Copied from Slave
#

ENV JENKINS_SWARM_VERSION 1.24
ENV LANG en_US.UTF-8

WORKDIR /tmp
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

COPY jenkins-slave.sh /tmp/jenkins-slave.sh
ENTRYPOINT ["/tmp/jenkins-slave.sh"]
