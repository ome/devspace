FROM openmicroscopy/devslave-c7:0.6.1

MAINTAINER OME

ARG JAVAVER=openjdk1.8
ARG ICEVER=ice36

# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

ENV OMERO_INSTALL_ROOT=/tmp/omero-install
## update omero-install to the latest one
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.email "you@example.com"
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.name "Your Name"
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT remote add username https://github.com/username/omero-install.git
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch username
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge username/yourbranch


ADD ./settings.env $OMERO_INSTALL/settings.env
RUN chmod +x $OMERO_INSTALL/settings.env

# Customize: run particular scripts from omero-install
RUN rm -f $OMERO_INSTALL/setup_centos_selinux.sh
RUN touch $OMERO_INSTALL/setup_centos_selinux.sh
# db will be managed by the job
RUN rm -f $OMERO_INSTALL/setup_omero_db.sh
RUN touch $OMERO_INSTALL/setup_omero_db.sh
RUN rm -f $OMERO_INSTALL/step03_all_postgres.sh
RUN touch $OMERO_INSTALL/step03_all_postgres.sh
# omeroweb will be installed by the job
RUN rm -f $OMERO_INSTALL/step04_all_omero.sh
RUN touch $OMERO_INSTALL/step04_all_omero.sh
# remove nginx
RUN rm -rf $OMERO_INSTALL/step05_centos7_nginx.sh
RUN touch $OMERO_INSTALL/step05_centos7_nginx.sh
# no systemd
RUN rm -rf $OMERO_INSTALL/step06_centos7_daemon.sh
RUN touch $OMERO_INSTALL/step06_centos7_daemon.sh
# no Pillow
RUN rm -rf $OMERO_INSTALL/requirements.txt
RUN touch $OMERO_INSTALL/requirements.txt

WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7_nginx.sh

# install postgres tools
RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-redhat94-9.4-3.noarch.rpm \
    && yum clean all
RUN yum -y install postgresql94 \
    && yum clean all

EXPOSE 4064
EXPOSE 4063

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh


# Install mencoder
# See https://github.com/ome/prod-playbooks/blob/7d8e59ced0b47a224d6be02907d913c392ef9379/ome-dundeeomero.yml#L48
RUN yum install -y http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
RUN yum install -y mencoder

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
VOLUME ['/home/omero']

USER omero
CMD ["/tmp/run.sh"]
