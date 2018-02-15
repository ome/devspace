FROM openmicroscopy/devslave-c7:0.3.1

MAINTAINER OME

ARG JAVAVER=openjdk18
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

RUN pip install Sphinx

# Install FindBugs
ENV FINDBUGS_VERSION 3.0.0
ENV FINDBUGS_HOME /opt/findbugs
RUN mkdir -p $FINDBUGS_HOME
RUN curl -fSLO http://downloads.sourceforge.net/project/findbugs/findbugs/$FINDBUGS_VERSION/findbugs-$FINDBUGS_VERSION.tar.gz && \
    tar xzf findbugs-$FINDBUGS_VERSION.tar.gz --strip-components 1 -C $FINDBUGS_HOME && \
    rm findbugs-$FINDBUGS_VERSION.tar.gz

# Install build tools from EPEL
RUN yum -y install maven ant && yum clean all

# install postgres tools
RUN yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm \
    && yum clean all
RUN yum -y install postgresql94 \
    && yum clean all

EXPOSE 14064
EXPOSE 14063

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh


# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
VOLUME ['/home/omero']

USER omero
CMD ["/tmp/run.sh"]
