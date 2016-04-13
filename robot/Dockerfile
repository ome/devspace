FROM openmicroscopy/devslave-c7:0.1.0

MAINTAINER OME

# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

# update omero-install to the latest one
ENV OMERO_INSTALL_ROOT=/tmp/omero-install
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch origin
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge origin/develop

# Customize: run particular scripts from omero-install
RUN bash $OMERO_INSTALL/step01_centos7_deps.sh
RUN export ICEVER=ice35-devel; bash /tmp/omero-install/linux/step01_centos7_ice_deps.sh

USER omero

RUN virtualenv /home/omero/omero-virtualenv --system-site-packages
RUN source /home/omero/omero-virtualenv/bin/activate; pip install robotframework
RUN source /home/omero/omero-virtualenv/bin/activate; pip install robotframework-selenium2library

USER root

WORKDIR /home/omero
