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

 *  Start up the jenkins slave (which starts up all requirements)::

        ./ds up      # Ctrl-C to stop or
        ./ds up -d   # To disconnect

 * Check that the containers are running:

        docker ps

 *  Configure artifactory:
    - Add an artifactory user (optional)
    - Under "System Configuration" add your artifactory URL

## Job workflow

The default deployment initializes a Jenkins server with a [predefined set of
jobs](homes/jobs). The table below lists the job names, the Jenkins node labels they are associated to and a short description of their:

| Job name                     | Name                 | Description                              |
| -----------------------------|----------------------| -----------------------------------------|
| Trigger                      |                      | Runs all the following jobs in order     |
| BIOFORMATS-push              | testice35            | Merges all Bio-Formats PRs               |
| BIOFORMATS-maven             | testice35            | Builds Bio-Formats and runs unit tests   |
| OMERO-push                   | testice35            | Merges all OMERO PRs                     |
| OMERO-build                  | testice35, testice36 | Builds OMERO artifacts (server, clients) |
| OMERO-server                 | omero                | Deploys an OMERO.server                  |
| OMERO-web                    | webice35             | Deploys an OMERO.web client              |
| OMERO-test-integration-ice35 | testice35            | Runs the OMERO integration tests ice35   |
| OMERO-test-integration-ice36 | testice36            | Runs the OMERO integration tests ice36   |
| OMERO-robot                  | robot                | Runs the Robot test                      |
| nginx                        | nginx                | Reloads the nginx server                 |
| -----------------------------|----------------------| -----------------------------------------|
