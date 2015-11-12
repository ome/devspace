FROM mini/base
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

ENV TAG 5.1.4

RUN apk-install git && \
    mkdir /src

RUN time git clone --bare --depth=1 -b v$TAG git://github.com/ome/scripts/ /src/scripts.git
RUN time git clone --bare --depth=1 -b v$TAG git://github.com/openmicroscopy/openmicroscopy /src/omero.git
RUN time git clone --bare --depth=1 -b v$TAG git://github.com/openmicroscopy/bioformats /src/bio-formats.git

WORKDIR /src
