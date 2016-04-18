FROM openmicroscopy/devslave-c7:0.1.0

MAINTAINER OME

RUN rm -f /lib/systemd/system/systemd*udev* ; \
    rm -f /lib/systemd/system/getty.target;

ARG USER_ID=1000
RUN usermod -u $USER_ID omero

RUN chmod a+X /home/omero

RUN yum -y localinstall http://nginx.org/packages/rhel/7/noarch/RPMS/nginx-release-rhel-7-0.el7.ngx.noarch.rpm \
    && yum clean all
RUN yum -y install nginx \
    && yum clean all
RUN mv /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.disabled

VOLUME ["/etc/nginx/conf.d", "/var/log/nginx"]

WORKDIR /etc/nginx

RUN systemctl enable nginx

EXPOSE 80 443
