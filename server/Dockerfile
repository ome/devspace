FROM openmicroscopy/omero-ssh-systemd

MAINTAINER OME

ENV JENKINS_SWARM_VERSION 2.0
ENV LANG en_US.UTF-8
ARG JAVAVER=openjdk18
ARG ICEVER=ice35-devel


# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

RUN yum install -y initscripts \
    && yum clean all

# Download and run omero-install. 
ENV OMERO_INSTALL /tmp/omero-install/linux
ARG TAG=5.2.3-m1

RUN yum install -y git \
    && yum clean all
RUN git clone -b v$TAG https://github.com/ome/omero-install.git /tmp/omero-install

ADD ./settings.env $OMERO_INSTALL/settings.env
RUN chmod +x $OMERO_INSTALL/settings.env

# Customize: run particular scripts from omero-install
RUN rm -f $OMERO_INSTALL/setup_centos_selinux.sh
RUN touch $OMERO_INSTALL/setup_centos_selinux.sh
# db will be managed by the job
RUN rm -f $OMERO_INSTALL/setup_omero_db.sh
RUN touch $OMERO_INSTALL/setup_omero_db.sh
RUN rm -f $OMERO_INSTALL/step03_all_postgres.sh
RUN touch $OMERO_INSTALL/step03_all_postgres.sh
# omeroweb will be installed by the job
RUN rm -f $OMERO_INSTALL/step04_all_omero.sh
RUN touch $OMERO_INSTALL/step04_all_omero.sh
# remove nginx
RUN rm -rf $OMERO_INSTALL/step05_centos7_nginx.sh
RUN touch $OMERO_INSTALL/step05_centos7_nginx.sh

RUN sed -i.bak -re 's/(.*postgresql-9.4.service.*)/#\1/' $OMERO_INSTALL/omero-systemd.service

RUN sed -i.bak -re 's/(.*omero-web.service.*)/#\1/' $OMERO_INSTALL/step06_centos7_daemon.sh
RUN sed -i.bak -re 's/(systemctl daemon-reload)/#\1/' $OMERO_INSTALL/step06_centos7_daemon.sh
 
WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7_nginx.sh

RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm
RUN yum -y install postgresql94

RUN yum install -y http://download-aws.ej-technologies.com/exe4j/exe4j_linux_5_0_1.rpm

WORKDIR /tmp

USER omero
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

USER root

ADD ./jenkins-slave.sh /tmp/jenkins-slave.sh
RUN chmod +x /tmp/jenkins-slave.sh
ADD ./jenkins.service /etc/systemd/system/jenkins.service
RUN systemctl enable jenkins.service

EXPOSE 4080


#ENTRYPOINT ["/tmp/jenkins-slave.sh"]
