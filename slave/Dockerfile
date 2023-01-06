FROM openmicroscopy/devslave-c7:0.7.2

MAINTAINER OME

ARG JAVAVER=openjdk11-devel
ARG ICEVER=ice36-devel
ARG BRANCH=scl_c7
ARG NAME=jburel


# skip some omero-install
RUN echo 'export container=docker' > /etc/profile.d/docker.sh

ENV OMERO_INSTALL_ROOT=/tmp/omero-install
## update omero-install to the latest one
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.email "you@example.com"
RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.name "Your Name"
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

# Switch Java version
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

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
RUN yum -y install postgresql13-server postgresql13 \
    && yum clean all

# gradle
RUN cd /opt && \
    curl -fSLO https://services.gradle.org/distributions/gradle-6.9.2-bin.zip && \
    unzip gradle-6.9.2-bin.zip && \
    rm gradle-6.9.2-bin.zip && \
    ln -s /opt/gradle-6.9.2/bin/gradle /usr/local/bin/gradle
    
EXPOSE 14064
EXPOSE 14063

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

ENV PATH=/opt/rh/rh-python38/root/usr/bin:$PATH

RUN python3 -m venv /py3 && /py3/bin/pip install -U pip tox future wheel restructuredtext-lint
RUN /py3/bin/pip install https://github.com/ome/zeroc-ice-py-centos7/releases/download/0.3.0/zeroc_ice-3.6.5-cp38-cp38-linux_x86_64.whl
RUN ln -s /py3/bin/slice2py /usr/bin/slice2py
ENV VIRTUAL_ENV=/py3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
VOLUME ["/home/omero"]

USER omero
CMD ["/tmp/run.sh"]
