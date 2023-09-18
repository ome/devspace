FROM jburel/devslave-c7:0.8.3

MAINTAINER OME

# Remove the existing omero user
RUN userdel -r omero && \
    echo 'root:omero' | chpasswd

# Create the omero-server user
RUN useradd omero-server && \
    echo 'omero-server:omero-server' | chpasswd && \
    echo "%omero-server ALL= (ALL) NOPASSWD: ALL" >> /etc/sudoers



ADD ./settings.env /home/settings.env
RUN chmod +x  /home/settings.env

WORKDIR /tmp/omero-install/linux


RUN dnf install -y python3

# Ice dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb
RUN dnf install -y openssl libdb-cxx
RUN cd /tmp && \
    wget -q https://github.com/sbesson/zeroc-ice-rockylinux9-x86_64/releases/download/20230720/Ice-3.6.5-rockylinux9-x86_64.tar.gz && \
    tar xf Ice-3.6.5-rockylinux9-x86_64.tar.gz && \
    mv Ice-3.6.5 /opt/ice-3.6.5 && \
    echo /opt/ice-3.6.5/lib64 > /etc/ld.so.conf.d/ice-x86_64.conf && \
    ldconfig
ENV ICE_HOME=/opt/ice-3.6.5

ENV PATH=$ICE_HOME/bin:$PATH

# install postgres tools
RUN dnf -y install postgresql \
    && dnf clean all


EXPOSE 4064
EXPOSE 4063

ADD ./run.sh /tmp/run.sh
RUN chown omero-server:omero-server /tmp/run.sh
RUN chmod a+x /tmp/run.sh


# Install mencoder
# See https://github.com/ome/prod-playbooks/blob/7d8e59ced0b47a224d6be02907d913c392ef9379/ome-dundeeomero.yml#L48
# RUN dnf install -y http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
# RUN dnf install -y mencoder


# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero-server

# make sure mounted volumes has correct permissions
VOLUME ["/home/omero-server"]

USER omero-server
CMD ["/tmp/run.sh"]
