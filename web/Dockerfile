FROM jburel/devslave-c7:0.8.3

MAINTAINER OME

# Remove the existing omero user
RUN userdel -r omero && \
    echo 'root:omero' | chpasswd

# Create the omero-web user
RUN useradd omero-web && \
	echo 'omero-web:omero-web' | chpasswd && \
	echo "%omero-web ALL= (ALL) NOPASSWD: ALL" >> /etc/sudoers

ADD ./settings.env  /home/settings.env
RUN chmod +x /home/settings.env

# ant for iviewer, make for nodejs
RUN dnf -y install ant make
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash
RUN dnf install -y nodejs
# grunt for figure
RUN npm install -g grunt


EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero-web:omero-web /tmp/run.sh
RUN chmod a+x /tmp/run.sh

RUN dnf install -y python3 openssl

RUN dnf clean all

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
