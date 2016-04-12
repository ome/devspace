FROM openmicroscopy/devslave-c7-docker:0.1.0

MAINTAINER OME

ENV ICEVER=ice35-devel

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

# install postgres tools
RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm \
    && yum clean all
RUN yum -y install postgresql94 \
    && yum clean all

WORKDIR /tmp

USER root

EXPOSE 4080
