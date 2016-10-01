FROM openmicroscopy/devslave-c7:0.2.1
MAINTAINER OME

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero
