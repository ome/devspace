FROM openmicroscopy/devslave-c7:0.7.2

MAINTAINER OME

ARG JAVAVER=openjdk1.8
ARG ICEVER=ice36
ARG BRANCH=scl_c7
ARG NAME=jburel

# Remove the existing omero user
RUN userdel -r omero && \
    rm -f /etc/sudoers.d/omero && \
    echo 'root:omero' | chpasswd

# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

ENV OMERO_INSTALL_ROOT=/tmp/omero-install

## update omero-install to the latest one
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.email "you@example.com"
#RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.name "Your Name"
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT remote add $NAME https://github.com/$NAME/omero-install.git
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch $NAME
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge $NAME/$BRANCH


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
# no systemd
RUN rm -rf $OMERO_INSTALL/step06_centos7_daemon.sh
RUN touch $OMERO_INSTALL/step06_centos7_daemon.sh
# no Pillow
RUN rm -rf $OMERO_INSTALL/requirements.txt
RUN touch $OMERO_INSTALL/requirements.txt

WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7.sh

# install postgres tools
RUN yum -y install postgresql10 \
    && yum clean all

EXPOSE 4064
EXPOSE 4063

ADD ./run.sh /tmp/run.sh
RUN chown omero-server:omero-server /tmp/run.sh
RUN chmod a+x /tmp/run.sh

RUN yum install -y python36
RUN python3 -m venv /py3 && /py3/bin/pip install -U pip tox future wheel restructuredtext-lint
RUN /py3/bin/pip install https://github.com/ome/zeroc-ice-py-centos7/releases/download/0.2.1/zeroc_ice-3.6.5-cp36-cp36m-linux_x86_64.whl
ENV VIRTUAL_ENV=/py3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install mencoder
# See https://github.com/ome/prod-playbooks/blob/7d8e59ced0b47a224d6be02907d913c392ef9379/ome-dundeeomero.yml#L48
RUN yum install -y http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
RUN yum install -y mencoder

RUN yum install -y openssl

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero-server

# make sure mounted volumes has correct permissions
VOLUME ["/home/omero-server"]

USER omero-server
CMD ["/tmp/run.sh"]
