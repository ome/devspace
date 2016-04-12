FROM openmicroscopy/devslave-c7-docker:0.1.0

MAINTAINER OME

# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

# Customize: run particular scripts from omero-install
RUN bash $OMERO_INSTALL/step01_centos7_deps.sh
RUN export ICEVER=ice35-devel; bash /tmp/omero-install/linux/step01_centos7_ice_deps.sh

USER omero

RUN virtualenv /home/omero/omero-virtualenv --system-site-packages
RUN source /home/omero/omero-virtualenv/bin/activate; pip install robotframework
RUN source /home/omero/omero-virtualenv/bin/activate; pip install robotframework-selenium2library

USER root

WORKDIR /home/omero
