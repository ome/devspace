FROM jburel/devslave-c7:0.8.5

MAINTAINER OME

COPY nginx-stable.repo /etc/yum.repos.d/
RUN dnf -y install dnf-utils
RUN yum-config-manager --enable nginx-stable

RUN dnf -y install nginx\
    && dnf clean all

# comment out default server config in nginx.conf
RUN sed -i "/^\s\s\s\sserver/, /^\s\s\s\s}/ s|^|#|" /etc/nginx/nginx.conf

VOLUME ["/etc/nginx/conf.d", "/var/log/nginx"]

WORKDIR /etc/nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

# workaround to avoid 403 on static files
RUN chmod a+x /home/omero

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
RUN mkdir -p /home/omero/static
RUN chown -R omero:omero /home/omero/static

VOLUME ["/etc/nginx/conf.d", "/home/omero/static", "/var/log/nginx", "/etc/nginx/ssl"]

USER omero
CMD ["/tmp/run.sh"]
