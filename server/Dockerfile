FROM openmicroscopy/devagent:0.8.2

LABEL org.opencontainers.image.authors="OME"


ADD ./settings.env /home/settings.env
RUN chmod +x  /home/settings.env

WORKDIR /tmp/omero-install/linux


RUN dnf install -y python3.11 python3.11-pip
RUN pip3.11 install build

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

# install postgres tools for pg16 (default is 13)
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf -qy module disable postgresql

RUN dnf -y install postgresql16 \
    && dnf clean all

# For OME-zarr
RUN dnf -y install epel-release
RUN dnf -y update
RUN dnf -y install blosc

# Add cron job to rotate java versions
ADD ./root /var/spool/cron/
RUN chmod +x  /var/spool/cron/root


EXPOSE 4064
EXPOSE 4063

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh


# Install mencoder
# See https://github.com/ome/prod-playbooks/blob/7d8e59ced0b47a224d6be02907d913c392ef9379/ome-dundeeomero.yml#L48
# RUN dnf install -y http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
# RUN dnf install -y mencoder


# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero



# make sure mounted volumes has correct permissions
VOLUME ["/home/omero"]

USER omero
CMD ["/tmp/run.sh"]
