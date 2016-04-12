FROM openmicroscopy/devslave-c7-docker:0.1.0

MAINTAINER OME


ADD ./settings.env $OMERO_INSTALL/settings.env
RUN chmod +x $OMERO_INSTALL/settings.env

# Customize: run particular scripts from omero-install
RUN rm -f $OMERO_INSTALL/setup_centos_selinux.sh
RUN touch $OMERO_INSTALL/setup_centos_selinux.sh
RUN rm -f $OMERO_INSTALL/setup_omero_db.sh
RUN touch $OMERO_INSTALL/setup_omero_db.sh
# do not create user
RUN rm -f $OMERO_INSTALL/step02_all_setup.sh
RUN touch $OMERO_INSTALL/step02_all_setup.sh
# omeroweb will be isntalled by the job
RUN rm -f $OMERO_INSTALL/step04_all_omero.sh
RUN touch $OMERO_INSTALL/step04_all_omero.sh
# remove nginx
RUN mv $OMERO_INSTALL/step05_centos7_nginx.sh $OMERO_INSTALL/_step05_centos7_nginx.sh
RUN touch $OMERO_INSTALL/step05_centos7_nginx.sh

RUN sed -i.bak -re 's/(Requires=nginx.service)/#\1/' $OMERO_INSTALL/omero-web-systemd.service
# TODO: remove when omero-install support virtualenv
# custom omero-web.service that support virtualenv
RUN rm -f $OMERO_INSTALL/omero-web-systemd.service
ADD ./omeroweb.service $OMERO_INSTALL/omero-web-systemd.service
#RUN chmod a $OMERO_INSTALL/omero-web-systemd.service

RUN sed -i.bak -re 's/(.*omero.service.*)/#\1/' $OMERO_INSTALL/step06_centos7_daemon.sh
RUN sed -i.bak -re 's/(systemctl daemon-reload)/#\1/' $OMERO_INSTALL/step06_centos7_daemon.sh
 
WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER PGVER=nopg bash install_centos7_nginx.sh
RUN yum install -y python-redis && yum clean all

WORKDIR /tmp

EXPOSE 4080
