FROM openmicroscopy/devslave-c7:0.2.1
MAINTAINER OME

# Install FindBugs
ENV FINDBUGS_VERSION 3.0.0
ENV FINDBUGS_HOME /opt/findbugs
RUN mkdir -p $FINDBUGS_HOME
RUN curl -fSLO http://downloads.sourceforge.net/project/findbugs/findbugs/$FINDBUGS_VERSION/findbugs-$FINDBUGS_VERSION.tar.gz && \
    tar xzf findbugs-$FINDBUGS_VERSION.tar.gz -C $FINDBUGS_HOME && \
    rm findbugs-$FINDBUGS_VERSION.tar.gz

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero
