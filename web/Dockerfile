FROM jburel/devslave-c7:0.8.1

MAINTAINER OME

ARG ICEVER=noice

# make ICEVERSION environment variable to use in OMERO-web job
ENV ICEVERSION ${ICEVER:-noice}


# Remove the existing omero user
RUN userdel -r omero && \
    echo 'root:omero' | chpasswd

# Create the omero-web user
RUN useradd omero-web && \
	echo 'omero-web:omero-web' | chpasswd && \
	echo "%omero-web ALL= (ALL) NOPASSWD: ALL" >> /etc/sudoers


# manually install ICEPY dependences
RUN dnf -y install gcc-c++
# ant for iviewer, make for nodejs
RUN dnf -y install ant make
RUN dnf -y install openssl-devel bzip2-devel expat-devel
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash
RUN dnf install -y nodejs
# grunt for figure
RUN npm install -g grunt


EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero-web:omero-web /tmp/run.sh
RUN chmod a+x /tmp/run.sh

RUN dnf install -y python3

RUN dnf clean all
RUN python3 -m venv /py3 && /py3/bin/pip install -U pip tox future wheel restructuredtext-lint
RUN /py3/bin/pip install https://github.com/glencoesoftware/zeroc-ice-py-rhel9-x86_64/releases/download/20230830/zeroc_ice-3.6.5-cp39-cp39-linux_x86_64.whl
RUN /py3/bin/pip install redis
ENV VIRTUAL_ENV=/py3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero-web

RUN chown -R omero-web:omero-web /home/omero-web/

# make sure mounted volumes has correct permissions
RUN mkdir -p /home/omero-web/nginx
RUN chown -R omero-web:omero-web /home/omero-web/nginx
RUN mkdir -p /home/omero-web/static
RUN chown -R omero-web:omero-web /home/omero-web/static

VOLUME ["/home/omero-web", "/home/omero-web/nginx"]

USER omero-web
CMD ["/tmp/run.sh"]
