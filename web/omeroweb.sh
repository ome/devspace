#!/bin/bash

# Setup and run omero

set -eux

echo Downloading ${1}
OMERO_ZIP=`echo "$1" | rev | cut -d / -f 1 | rev`
OMERO_ZIP="${OMERO_ZIP%.*}"

curl -o ~omero/$OMERO_ZIP.zip ${1} && \
    unzip -d /home/omero $OMERO_ZIP.zip && \
    ln -s ~omero/$OMERO_ZIP ~omero/OMERO.py && \
    rm $OMERO_ZIP.zip

virtualenv /home/omero/omeropy-virtualenv --system-site-packages

# Get pip to download and install requirements:

set +o nounset
source ~omero/omeropy-virtualenv/bin/activate
set -o nounset

pip install --upgrade pip
pip install --upgrade 'Pillow<3.0'
pip install --upgrade -r ~omero/OMERO.py/share/web/requirements-py27-nginx.txt

# configure nginx
/home/omero/OMERO.py/bin/omero config set omero.web.application_server wsgi-tcp
/home/omero/OMERO.py/bin/omero web config nginx > /home/omero/omero-web.conf.tmp

sudo cp /home/omero/omero-web.conf.tmp  /etc/nginx/conf.d/omero-web.conf
