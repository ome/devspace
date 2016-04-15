FROM openmicroscopy/devslave-c7:0.1.0

MAINTAINER OME

RUN rm -f /lib/systemd/system/systemd*udev* ; \
    rm -f /lib/systemd/system/getty.target;

ARG ICEVER=noice

# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

# update omero-install to the latest one
ENV OMERO_INSTALL_ROOT=/tmp/omero-install
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch origin
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge origin/develop

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

RUN sed -i.bak -re 's/(systemctl enable omero.service)/#\1/' $OMERO_INSTALL/step06_centos7_daemon.sh
 
WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7_nginx.sh
# manually install ICEPY dependences
RUN yum -y install gcc-c++
RUN yum -y install openssl-devel bzip2-devel expat-devel

RUN yum install -y python-redis && yum clean all

EXPOSE 4080
