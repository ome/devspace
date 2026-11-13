FROM openmicroscopy/devagent:0.8.2

LABEL org.opencontainers.image.authors="OME"

ARG NAME=ome

ARG GRADLEVER=6.9.3

ADD ./settings.env  /home/settings.env
RUN chmod +x /home/settings.env


# Required for the docs build
RUN dnf install -y make

# Python job: refresh certificates and update pip before installing packages
RUN dnf install -y ca-certificates python3.11 python3.11-pip && \
    dnf upgrade -y ca-certificates && \
    update-ca-trust

RUN python3.11 -m pip install \
    "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"

RUN python3.11 -m pip install --upgrade "certifi>=2026.10.23"

RUN python3.11 -m pip install build

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
RUN sed -i \
    's/rhel-\$releasever_major\.\$releasever_minor-/rhel-\$releasever_major-/g' \
    /etc/yum.repos.d/pgdg-redhat-all.repo && \
    dnf --disablerepo="pgdg*" -qy module disable postgresql
RUN dnf -y install postgresql16-server postgresql16 \
    && dnf clean all

# gradle
RUN cd /opt && \
    curl -fSLO https://services.gradle.org/distributions/gradle-$GRADLEVER-bin.zip && \
    unzip gradle-$GRADLEVER-bin.zip && \
    rm gradle-$GRADLEVER-bin.zip && \
    ln -s /opt/gradle-$GRADLEVER/bin/gradle /usr/local/bin/gradle


# For OME-zarr
RUN dnf -y install epel-release
RUN dnf -y update
RUN dnf -y install blosc

RUN dnf install -y cronie
RUN update-alternatives --set java java-21-openjdk.x86_64
EXPOSE 14064
EXPOSE 14063

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

# Change user id to fix permissions issues
ARG USER_ID=11593
RUN usermod -u $USER_ID omero

# make sure mounted volumes has correct permissions
VOLUME ["/home/omero"]

USER omero
CMD ["/tmp/run.sh"]
