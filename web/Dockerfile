FROM openmicroscopy/devslave-c7:0.2.0

MAINTAINER OME

ARG JAVAVER=${JAVAVER:-openjdk18}
ARG ICEVER=${ICEVER:-noice}

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
# no systemd
RUN rm -rf $OMERO_INSTALL/step06_centos7_daemon.sh
RUN touch $OMERO_INSTALL/step06_centos7_daemon.sh

WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7_nginx.sh
# manually install ICEPY dependences
RUN yum -y install gcc-c++
RUN yum -y install openssl-devel bzip2-devel expat-devel

RUN yum install -y python-redis && yum clean all

EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh


# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

USER omero
CMD ["/tmp/run.sh"]
