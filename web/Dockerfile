FROM openmicroscopy/devagent:0.8.1

MAINTAINER OME

ADD ./settings.env  /home/settings.env
RUN chmod +x /home/settings.env

# ant for iviewer, make for nodejs
RUN dnf -y install ant make
RUN curl -sL https://rpm.nodesource.com/setup_20.x | bash
RUN dnf install -y nodejs
# grunt for figure
RUN npm install -g grunt


EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

RUN dnf install -y python3.11 openssl python3.11-pip
RUN pip3.11 install build

RUN dnf clean all

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

RUN chown -R omero:omero /home/omero/

# make sure mounted volumes has correct permissions
RUN mkdir -p /home/omero/nginx
RUN chown -R omero:omero /home/omero/nginx
RUN mkdir -p /home/omero/static
RUN chown -R omero:omero /home/omero/static

VOLUME ["/home/omero", "/home/omero/nginx"]

USER omero
CMD ["/tmp/run.sh"]
