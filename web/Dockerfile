FROM openmicroscopy/devslave-c7:latest
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

USER root

# Likely remove
#RUN sed -i.bak -re 's/( default_server.*)/; #\1/' /etc/nginx/nginx.conf
#ADD ./omeroweb.sh /home/omero/omeroweb.sh
#RUN chown omero:omero /home/omero/omeroweb.sh
#RUN chmod +x /home/omero/omeroweb.sh
#RUN chmod a+X /home/omero

EXPOSE 80

# Configuration for a general slave
# Note: a JDK MUST be installed above.
RUN usermod -u 11521 omero

# Ola new commit
ADD ./omeroweb.service /etc/systemd/system/omeroweb.service
RUN ln -s /etc/systemd/system/omeroweb.service /etc/systemd/system/multi-user.target.wants/omeroweb.service

# AS OMERO user
USER omero
ENV HOME /home/omero
WORKDIR /home/omero
