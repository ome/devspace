FROM openmicroscopy/devslave-c7:0.6.1

MAINTAINER OME

ARG JAVAVER=openjdk1.8
ARG ICEVER=noice

# make ICEVERSION environment variable to use in OMERO-web job
ENV ICEVERSION ${ICEVER:-noice}

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
RUN rm -f $OMERO_INSTALL/setup_omero_db.sh
RUN touch $OMERO_INSTALL/setup_omero_db.sh
# do not create user
RUN rm -f $OMERO_INSTALL/step02_all_setup.sh
RUN touch $OMERO_INSTALL/step02_all_setup.sh
# omeroweb will be isntalled by the job
RUN rm -f $OMERO_INSTALL/step04_all_omero.sh
RUN touch $OMERO_INSTALL/step04_all_omero.sh
# remove nginx
RUN mv $OMERO_INSTALL/step05_centos7_nginx.sh $OMERO_INSTALL/_step05_centos7_nginx.sh
RUN touch $OMERO_INSTALL/step05_centos7_nginx.sh
# no systemd
RUN rm -rf $OMERO_INSTALL/step06_centos7_daemon.sh
RUN touch $OMERO_INSTALL/step06_centos7_daemon.sh
# no Pillow
RUN rm -rf $OMERO_INSTALL/requirements.txt
RUN touch $OMERO_INSTALL/requirements.txt

WORKDIR /tmp/omero-install/linux

RUN JAVAVER=$JAVAVER ICEVER=$ICEVER PGVER=nopg bash install_centos7_nginx.sh

# manually install ICEPY dependences
RUN yum -y install gcc-c++
# ant for iviewer, make for nodejs
RUN yum -y install ant make
RUN yum -y install openssl-devel bzip2-devel expat-devel
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash
RUN yum install -y nodejs
# grunt for figure
RUN npm install -g grunt

RUN yum install -y python-redis && yum clean all

EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

RUN yum install -y python36
RUN python3 -m venv /py3 && /py3/bin/pip install -U pip tox future wheel restructuredtext-lint
RUN /py3/bin/pip install https://github.com/ome/zeroc-ice-py-centos7/releases/download/0.2.1/zeroc_ice-3.6.5-cp36-cp36m-linux_x86_64.whl
RUN /py3/bin/pip install scc
ENV VIRTUAL_ENV=/py3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
RUN mkdir -p /home/omero/nginx
RUN chown -R omero:omero /home/omero/nginx

VOLUME ['/home/omero', '/home/omero/nginx']

USER omero
CMD ["/tmp/run.sh"]
