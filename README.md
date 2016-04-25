# Getting started

## Requirements

The following prerequisites are required for deploying a Jenkins devspace:

*   Docker Engine 1.9.1 or later
*   Docker Compose 1.6.2

    If Docker Compose cannot be isntalled globally follow https://docs.docker.com/compose/install/
    On CentOS7 use Miniconda

## Deployment

 *  Clone devspace to a directory with a meaningful name, since this will be
    part of your docker container names:

        git clone git://github.com/openmicroscopy/devspace MYTOPIC

 *  Run `rename.py` to match your topic name. If you do not yet have
    topic branches available on origin, use "develop" or one of the
    main branches.

        ./rename.py MYTOPIC

 *  Optionally, commit those changes to a new branch:

        git checkout -b MYTOPIC && git commit -a -m "Start MYTOPIC branch"

 *  Configure the .ssh and .gitconfig files in the slave directory, e.g.:

        cp ~/.gitconfig slave/
        cp ~/.ssh/id_rsa slave/.ssh
        cp ~/.ssh/id_rsa.pub slave/.ssh
        ssh-keyscan github.com >> slave/.ssh/known_hosts

 *  **If not using docker-machine**, you will need to fix the user ID
    for jenkins and slave!

    devspace uses docker-compose V1 that do not support build arguments
    you have to add the following manually to each systemd based container,
    for example (where 1234 is your user ID):

        diff --git a/web/Dockerfile b/web/Dockerfile
        index f86703e..11bdc04 100644
        --- a/web/Dockerfile
        +++ b/web/Dockerfile
        @@ -51,7 +51,7 @@ RUN chmod a+x /tmp/run.sh


         # Change user id to fix permissions issues
        -ARG USER_ID=1000
        +ARG USER_ID=1234
         RUN usermod -u $USER_ID omero

 *  Build containers

        ./ds build

 *  Start up the devspace (which starts up all requirements):

        ./ds up      # Ctrl-C to stop or
        ./ds up -d   # To disconnect

    On OSX

        EXTRA=docker-compose.osx.yml ./ds up      # Ctrl-C to stop or
        EXTRA=docker-compose.osx.yml ./ds up -d   # To disconnect

 * Check that the containers are running:

        docker ps

 *  Configure artifactory:
    - Add an artifactory user (optional)
    - Under "System Configuration" add your artifactory URL

## Service script

    Once successfully deployed add systemd service script to manage the devspace

        /etc/systemd/system/docker-devspace.service
        [Unit]
        Description=Docker devspace CI
        Requires=docker.service
        BindsTo=docker.service
        After=docker.service

        [Service]
        Restart=always
        RestartSec=10
        User=YOUR_USERNAME
        WorkingDirectory=/path/to/devspace/MYTOPIC
        ExecStart=/usr/bin/bash -c "./ds up"
        ExecStop=/usr/bin/bash -c "./ds stop"

        [Install]
        WantedBy=multi-user.target

    If docker compose is not installed globally and you use miniconda

        /etc/systemd/system/docker-devspace.service
        [Unit]
        Description=Docker devspace CI
        Requires=docker.service
        BindsTo=docker.service
        After=docker.service

        [Service]
        Restart=always
        RestartSec=10
        User=YOUR_USERNAME
        WorkingDirectory=/path/to/devspace/MYTOPIC
        Environment="DCPATH=/path/to/miniconda/bin"
        ExecStart=/usr/bin/bash -c "PATH=$PATH:$DCPATH; ./ds up"
        ExecStop=/usr/bin/bash -c "PATH=$PATH:$DCPATH; ./ds stop"

        [Install]
        WantedBy=multi-user.target

## Job workflow


The default deployment initializes a Jenkins server with a [predefined set of
jobs](homes/jobs). The table below lists the job names, the Jenkins node labels
they are associated to and a short description of their:

| Job name               | Name            | Description                               |
| -----------------------|-----------------| ------------------------------------------|
| Trigger                |                 | Runs all the following jobs in order      |
| BIOFORMATS-push        | testintegration | Merges all Bio-Formats PRs                |
| BIOFORMATS-maven       | testintegration | Builds Bio-Formats and runs unit tests    |
| OMERO-push             | testintegration | Merges all OMERO PRs                      |
| OMERO-build            | testintegration | Builds OMERO artifacts (server, clients)  |
| OMERO-server           | omero           | Deploys an OMERO.server                   |
| OMERO-web              | web             | Deploys an OMERO.web client               |
| OMERO-test-integration | testintegration | Runs the OMERO integration tests          |
| OMERO-robot            | testintegration | Runs the Robot test                       |
| nginx                  | nginx           | Reloads the nginx server                  |
| -----------------------|-----------------| ------------------------------------------|

Default packages:

| Name       | Version       | Optional                           |
| ----------------------------------------------------------------|
| Java       | openJDK 1.8   | openJDK 1.8 devel, oracleJDK 1.8   |
| Python     | 2.7           | -                                  |
| Ice        | 3.6           | 3.5                                |
| PostgreSQL | latest        | https://hub.docker.com/_/postgres/ |
| Nginx      | 1.8           | -                                  |
| Redis      | latest        | https://hub.docker.com/_/redis/    |

## Upgrade

If you made custom adjustments to the code and commited them, it is recomanded to reset changes.

Here are listed the most important changes:

 * Compose configuration was splitted into a few different files depends on the platform

        - docker-compose.yml mian file
        - docker-compose.unixports.yml required for running container on UNIX platform
        - docker-compose.osx.yml required for running containers on OSX platform

   For how to run check deployment

 * All nodes are now systemd nodes that requires adjusting the permissions. For what to change
   see deployment.

        - **Do not change Dockerfile** as this will load your USERID automaticaly
          If you did it in the past remove the change.

        - slave node:
          Since slave container user has changed from slave to omero.
          If you want to preserve the history, once you start your new devspace, you have to
          manually chown all files that belongs to slave user.

          `find . -user slave -group slave -exec chown omero:omero`
          `find . -user slave -group 8000 -exec chown omero:8000`
          `usermod -u 1234 omero`

 *  Run `rename.py` to match your topic name. If you do not yet have
    topic branches available on origin, use "develop" or one of the
    main branches.

        ./rename.py MYTOPIC
 
    Ignore the error
