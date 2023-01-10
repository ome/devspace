FROM mini/base
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

ENV TAGSERVER 5.6.5
ENV TAGSCRIPTS 5.7.1
ENV TAGBF 6.11.1

RUN apk-install git && \
    mkdir /src

RUN time git clone --bare --depth=1 -b v$TAGSCRIPTS https://github.com/ome/scripts/ /src/scripts.git
RUN time git clone --bare --depth=1 -b vTAGSERVER https://github.com/ome/openmicroscopy /src/omero.git
RUN time git clone --bare --depth=1 -b vTAGBF https://github.com/ome/bioformats /src/bio-formats.git

WORKDIR /src
