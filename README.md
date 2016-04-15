# Getting started

## Requirements

The following prerequisites are required for deploying a Jenkins devspace:

*   Docker Compose 1.6.2
*   Docker Engine 1.9.1 or later

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

 * Configure the .ssh and .gitconfig files in the slave directory, e.g.:

        cp ~/.gitconfig slave/
        cp ~/.ssh/id_rsa slave/.ssh
        cp ~/.ssh/id_rsa.pub slave/.ssh

 * **If not using docker-machine**, you will need to fix the user ID
    for jenkins and slave!

    devspace uses docker-compose V1 that do not support build arguments
    you have to add the following manually to each systemd based container,
    for example (where 1234 is your user ID):

        diff --git a/slave2/Dockerfile b/slave2/Dockerfile
        index 91a1eba..c9fb0b7 100644
        --- a/slave2/Dockerfile
        +++ b/slave2/Dockerfile
        @@ -7,6 +7,8 @@ RUN rm -f /lib/systemd/system/systemd*udev* ; \

         ARG ICEVER=ice36

        +RUN usermod -u 1234 omero
        +
         # skip some omero-install
         RUN echo 'export container=docker' > /etc/profile.d/docker.sh

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

## Job workflow

The default deployment initializes a Jenkins server with a [predefined set of
jobs](homes/jobs). The table below lists the job names, the Jenkins node labels
they are associated to and a short description of their:

| Job name               | Name                 | Description                               |
| -----------------------|----------------------| ------------------------------------------|
| Trigger                |                      | Runs all the following jobs in order      |
| BIOFORMATS-push        | testice35            | Merges all Bio-Formats PRs                |
| BIOFORMATS-maven       | testice35            | Builds Bio-Formats and runs unit tests    |
| OMERO-push             | testice35            | Merges all OMERO PRs                      |
| OMERO-build            | testice35, testice36 | Builds OMERO artifacts (server, clients)  |
| OMERO-server           | omero                | Deploys an OMERO.server                   |
| OMERO-web              | webice35             | Deploys an OMERO.web client               |
| OMERO-test-integration | testice35, testice36 | Runs the OMERO integration tests ice35/36 |
| OMERO-robot            | robot                | Runs the Robot test                       |
| nginx                  | nginx                | Reloads the nginx server                  |
| -----------------------|----------------------| ------------------------------------------|


## Upgrade

If you made custom adjustments to the code and commited them, it is recomanded to reset changes,
otherwise you will have to resolve conflicts manually

Here are listed the most important changes:

 * Compose configuration was splitted into a few different files depends on the platform

        - docker-compose.yml mian file
        - docker-compose.unix.yml required for running systemd container on UNIX platform
        - docker-compose.osx.yml required for running systemd containers on OSX platform

   For how to run check deployment

 * All nodes are now systemd nodes that requires adjusting the permissions. For what to change
   see deployment.

        - jenkins node:
          **Do not change jenkins/Dockerfile** as this will load your USERID automaticaly
          If you did it in the past remove the change.

        - slave node:
          Since slave container moved to systemd, user has changed from slave to omero.
          If you want to preserve the history, once you start your new devspace, you have to
          manually chown all files that belongs to slave user.

          `find . -user slave -group slave -exec chown omero:omero`
          `find . -user slave -group 8000 -exec chown omero:8000`
          `usermod -u 1234 omero`

        - OMERO-build and OMERO-test-integration jobs become matrix projects and history may look
          odd. Although entire history oj these jobs should be preserved.

        - 

 *  Run `rename.py` to match your topic name. If you do not yet have
    topic branches available on origin, use "develop" or one of the
    main branches.

        ./rename.py MYTOPIC
 
    If you didn;t remove those changes, then grep

 * **If not using docker-machine**, you will need to fix the user ID
    for jenkins and slave!
