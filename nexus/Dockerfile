FROM sonatype/nexus3:3.19.1

USER root
RUN yum install -y -q python3 && \
    python3 -mvenv /venv && \
    /venv/bin/pip install https://github.com/thiagofigueiro/nexus3-cli/archive/6896fc860d66fe2bf59ebc739ae8dbb7d45d328d.zip
    # /venv/bin/pip install nexus3-cli==2.1.0
ADD initialise-repos.py /

# Devspace runs everything as a custom UID, so need to update internal user if USER_ID set
ARG USER_ID=200
RUN usermod -u "${USER_ID}" nexus
USER nexus
