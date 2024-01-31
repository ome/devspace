FROM jburel/devslave-c7:0.8.7

MAINTAINER OME

ARG NAME=ome

ARG GRADLEVER=6.9.3

ADD ./settings.env  /home/settings.env
RUN chmod +x /home/settings.env


# Required for the docs build
RUN dnf install -y make

# Python job
RUN dnf install -y python3-setuptools
# Ice dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb
RUN dnf install -y openssl libdb-cxx
RUN cd /tmp && \
    wget -q https://github.com/glencoesoftware/zeroc-ice-rhel9-x86_64/releases/download/20230928/Ice-3.6.5-rhel9-x86_64.tar.gz && \
    tar xf Ice-3.6.5-rhel9-x86_64.tar.gz && \
    mv Ice-3.6.5 /opt/ice-3.6.5 && \
    echo /opt/ice-3.6.5/lib64 > /etc/ld.so.conf.d/ice-x86_64.conf && \
    ldconfig

ENV ICE_HOME=/opt/ice-3.6.5

ENV PATH=$ICE_HOME/bin:$PATH

# Install FindBugs
ENV FINDBUGS_VERSION 3.0.0
ENV FINDBUGS_HOME /opt/findbugs
RUN mkdir -p $FINDBUGS_HOME
RUN curl -fSLO http://downloads.sourceforge.net/project/findbugs/findbugs/$FINDBUGS_VERSION/findbugs-$FINDBUGS_VERSION.tar.gz && \
    tar xzf findbugs-$FINDBUGS_VERSION.tar.gz --strip-components 1 -C $FINDBUGS_HOME && \
    rm findbugs-$FINDBUGS_VERSION.tar.gz

# Install build tools from EPEL
RUN dnf -y install maven ant && dnf clean all

# install postgres tools for pg16 (default is 13)
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf -qy module disable postgresql
RUN dnf -y install postgresql16-server postgresql16\
    && dnf clean all

# gradle
RUN cd /opt && \
    curl -fSLO https://services.gradle.org/distributions/gradle-$GRADLEVER-bin.zip && \
    unzip gradle-$GRADLEVER-bin.zip && \
    rm gradle-$GRADLEVER-bin.zip && \
    ln -s /opt/gradle-$GRADLEVER/bin/gradle /usr/local/bin/gradle


EXPOSE 14064
EXPOSE 14063

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

<<<<<<< HEAD
ENV PATH=/opt/rh/rh-python38/root/usr/bin:$PATH
RUN python3 -m venv /py3 && /py3/bin/pip install -U pip tox build future wheel restructuredtext-lint
RUN /py3/bin/pip install https://github.com/ome/zeroc-ice-py-centos7/releases/download/0.3.0/zeroc_ice-3.6.5-cp38-cp38-linux_x86_64.whl
RUN ln -s /py3/bin/slice2py /usr/bin/slice2py
ENV VIRTUAL_ENV=/py3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

=======
>>>>>>> 9535936 (update dockerfile to work with rocky9)
# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
VOLUME ["/home/omero"]

USER omero
CMD ["/tmp/run.sh"]
