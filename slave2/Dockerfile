FROM openmicroscopy/devslave-c7:0.1.0

MAINTAINER OME

ARG ICEVER=ice36

# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

# update omero-install to the latest one
ENV OMERO_INSTALL_ROOT=/tmp/omero-install
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch origin
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge origin/develop

# TEST Ice36
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT remote add jburel https://github.com/jburel/omero-install.git
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch jburel
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge jburel/ice36-release

ADD ./settings.env $OMERO_INSTALL/settings.env
RUN chmod +x $OMERO_INSTALL/settings.env

ADD ./omero-systemd.service $OMERO_INSTALL/omero-systemd.service
RUN chmod +x $OMERO_INSTALL/omero-systemd.service

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

# add omero.service manually as we skip PG
RUN sed -i "1 a\cp omero-systemd.service /etc/systemd/system/omero.service" $OMERO_INSTALL/step06_centos7_daemon.sh

WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7_nginx.sh

# install sphinx
RUN pip install sphinx

# install postgres tools
RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm \
    && yum clean all
RUN yum -y install postgresql94 \
    && yum clean all

WORKDIR /tmp

EXPOSE 4080
