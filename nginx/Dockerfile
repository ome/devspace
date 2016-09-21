FROM openmicroscopy/devslave-c7:0.2.1

MAINTAINER OME

RUN yum -y localinstall http://nginx.org/packages/rhel/7/noarch/RPMS/nginx-release-rhel-7-0.el7.ngx.noarch.rpm \
    && yum clean all
RUN yum -y install nginx \
    && yum clean all
RUN mv /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.disabled

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

VOLUME ['/etc/nginx/conf.d', '/home/omero/static', '/var/log/nginx', '/etc/nginx/ssl']

USER omero
CMD ["/tmp/run.sh"]
