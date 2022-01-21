FROM jburel/devslave-c7-docker:0.6.9

MAINTAINER OME

ARG JAVAVER=openjdk1.8
ARG ICEVER=noice
ARG BRANCH=develop
# make ICEVERSION environment variable to use in OMERO-web job
ENV ICEVERSION ${ICEVER:-noice}


# Remove the existing omero user
RUN userdel -r omero && \
    rm -f /etc/sudoers.d/omero && \
    echo 'root:omero' | chpasswd

# Create the omero-web user
RUN useradd omero-web && \
	echo 'omero-web:omero-web' | chpasswd && \
	echo "omero-web ALL= (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/omero-web


# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

ENV OMERO_INSTALL_ROOT=/tmp/omero-install

ADD ./settings.env $OMERO_INSTALL/settings.env
RUN chmod +x $OMERO_INSTALL/settings.env

# manually install ICEPY dependences
RUN yum -y install gcc-c++
# ant for iviewer, make for nodejs
RUN yum -y install ant make
RUN yum -y install openssl-devel bzip2-devel expat-devel
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash
RUN yum install -y nodejs
# grunt for figure
RUN npm install -g grunt

RUN yum install -y python-redis && yum clean all

EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero-web:omero-web /tmp/run.sh
RUN chmod a+x /tmp/run.sh

RUN yum install -y python36
RUN python3 -m venv /py3 && /py3/bin/pip install -U pip tox future wheel restructuredtext-lint
RUN /py3/bin/pip install https://github.com/ome/zeroc-ice-py-centos7/releases/download/0.2.1/zeroc_ice-3.6.5-cp36-cp36m-linux_x86_64.whl
ENV VIRTUAL_ENV=/py3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero-web

# make sure mounted volumes has correct permissions
RUN mkdir -p /home/omero-web/nginx
RUN chown -R omero-web:omero-web /home/omero-web/nginx

VOLUME ["/home/omero-web", "/home/omero-web/nginx"]

USER omero-web
CMD ["/tmp/run.sh"]
