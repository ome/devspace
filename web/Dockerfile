FROM openmicroscopy/devagent:0.8.2

LABEL org.opencontainers.image.authors="OME"

ADD ./settings.env  /home/settings.env
RUN chmod +x /home/settings.env

# ant for iviewer, make for nodejs
RUN dnf -y install ant make
RUN curl -sL https://rpm.nodesource.com/setup_24.x | bash
RUN dnf install -y nodejs

EXPOSE 4080

ADD ./run.sh /tmp/run.sh
RUN chown omero:omero /tmp/run.sh
RUN chmod a+x /tmp/run.sh

# Install Python and refresh certificate trust before pip installs
RUN dnf install -y ca-certificates python3.11 openssl python3.11-pip && \
    dnf upgrade -y ca-certificates && \
    update-ca-trust

RUN python3.11 -m pip install \
    "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"

RUN python3.11 -m pip install --upgrade "certifi>=2026.10.23"

RUN python3.11 -m pip install build

RUN update-alternatives --set java java-21-openjdk.x86_64

RUN dnf clean all

# Change user id to fix permissions issues
ARG USER_ID=11593
RUN usermod -u $USER_ID omero

RUN chown -R omero:omero /home/omero/

# make sure mounted volumes has correct permissions
RUN mkdir -p /home/omero/nginx
RUN chown -R omero:omero /home/omero/nginx
RUN mkdir -p /home/omero/static
RUN chown -R omero:omero /home/omero/static

VOLUME ["/home/omero", "/home/omero/nginx"]

USER omero
CMD ["/tmp/run.sh"]
