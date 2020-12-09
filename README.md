# Getting started

Devspace is a Continuous Integration tool managed by [Jenkins CI](https://jenkins.io/) providing
an automation framework that runs repeated jobs. The default deployment
initializes a Jenkins CI master with a predefined set of jobs.


Running and maintaining Devspace requires brief understanding of:

*  [Docker engine](https://docs.docker.com/)
*  [Docker compose](https://docs.docker.com/compose/)

Running Devspace requires access to SSH and Git configuration files used for fetching and pushing the Git repositories.

Devspace code depends on the following repositories:

* [OMERO install](https://github.com/ome/omero-install/)
* [devslave-c7-docker](https://github.com/openmicroscopy/devslave-c7-docker)

# Installation

The following instructions explain how to deploy a devspace on a Docker host.

*   Log into the Docker host using ssh

*   Install the prerequisites [Docker engine](https://docs.docker.com/) and
    [Docker compose](https://docs.docker.com/compose/) either globally or in
    a virtual environment:

        $ pip install docker-compose

*   Create a directory ``/data/username`` and change ownership:

        $ sudo mkdir /data/username
        $ sudo chown username /data/username


*   Clone the ``devspace`` Git repository:

        $ git clone https://github.com/openmicroscopy/devspace.git
        $ cd devspace

*   Generated self-signed SSL certificates for the Jenkins and NGINX
    containers:

        $ ./sslcert jenkins/sslcert HOST_IP
        $ ./sslcert nginx/sslcert HOST_IP

    alternatively put your own certificate `.crt and .key` in the above locations.

*   Copy the SSH and Git configuration files used for fetching and pushing the
    Git repositories under `slave/.ssh` and `slave/.gitconfig`. This is usually
    your own SSH and Git configuration files.

 *  Run `rename.py` to match your topic name. Specify the Git user corresponding to
    the confguration files used above. If you do not yet have
    topic branches available on origin, use `develop` or one of the
    main branches:

        $ ./rename.py MYTOPIC --user git_user

*   This will also replace the `USER_ID` of the various Dockerfile with the ID of the user who
    will run the devspace, assumed to be: `id -u`, i.e. the current user.

*   Set the environment variables in `.env`, especially:

        JENKINS_USERNAME=devspace
        JENKINS_PASSWORD=<password>

*   Optionally, commit all the deployment changes above on the local clone of the devspace repository.

Start and configure:

*   Start devspace using `docker-compose`:

        $ docker-compose up -d

    By default, this will use the name of the directory as the project name. In the case of a shared Docker host, it is possible to override the project name using

        $ docker-compose up -p my_project -d

*   Retrieve the dynamic port of the Jenkins NGINX container. You can access
    the Jenkins UI from https://HOST_IP:PORT after accepting the self-signed
    certificate:

        $ docker-compose -p my_project port nginxjenkins 443

*   [Optional] Turn on Basic HTTP authentication for Jenkins

        sudo htpasswd -c jenkins/conf.d/passwdfile nginx

    and update `jenkins/conf.d/jenkins.conf`:

        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/conf.d/passwdfile;

*   [Optional] Create the `maven-internal` Nexus repository:

        $ docker-compose exec nexus /nexus-data/createRepoMavenInternal.sh


# GitHub OAuth

You can optionally enable GitHub OAuth:

*   Copy
    [`home/init.groovy.d/github-oauth.groovy.disabled`](home/init.groovy.d/github-oauth.groovy.disabled)
    to `home/init.groovy.d/github-oauth.groovy`
*   Create a [new GitHub app](https://github.com/settings/applications/new) and edit the variables at the top of `home/init.groovy.d/github-oauth.groovy`.
    The script also gives details of the required GitHub OAuth callback.
*   Restart Jenkins

Note: if you are modifying an existing devspace you are advised to backup `home/config.xml`.
If there are errors in the GitHub setup you can restore `home/config.xml` to return to the default authentication.

After the script has completed you can either leave it in place so it will override any manual changes on restart, or delete it and make changes through the Jenkins UI.


# Job configurations

# Job workflow

The default deployment initializes a Jenkins server with a [predefined set of
jobs](home/jobs).

The table below lists the job names, the Jenkins node labels and the associated docker
they are associated with and a short description of the jobs.

| Job name               | Name            | Description                               |     docker name            |
| -----------------------|-----------------| ------------------------------------------|----------------------------|
| Trigger                |                 | Runs all the following jobs in order      |                            |
| BIOFORMATS-push        | testintegration | Merges all Bio-Formats PRs                | devspace_testintegration_1 |
| BIOFORMATS-image       | testintegration | Builds a Docker image of Bio-Formats   | devspace_docker_1 D
| BIOFORMATS-deploy      | testintegration | Deploys the Bio-Formats components    | devspace_testintegration_1 |
| OMERO-push             | testintegration | Merges all OMERO PRs                      | devspace_testintegration_1 |
| OMERO-build            | testintegration | Builds OMERO artifacts (server, clients)  | devspace_testintegration_1 |
| OMERO-server           | omero           | Deploys an OMERO.server                   | devspace_omero_1           |
| OMERO-web              | web             | Deploys an OMERO.web client               | devspace_web_1             |
| OMERO-test-integration | testintegration | Runs the OMERO integration tests          | devspace_testintegration_1 |
| OMERO-robot            | testintegration | Runs the Robot tests                      | devspace_testintegration_1 |
| nginx                  | nginx           | Reloads the nginx server                  | devspace_nginx_1           |
| OMERO-docs             | testintegration | Builds the OMERO documentation            | devspace_testintegration_1 |


This means that by default the following repositories need to be
forked to your GitHub account:

* [openmiscrocopy/openmiscrocopy](https://github.com/openmicroscopy/openmicroscopy)
* [openmiscrocopy/ome-documentation](https://github.com/openmicroscopy/ome-documentation)
* [openmiscrocopy/bioformats](https://github.com/openmicroscopy/bioformats)

If you do not have some of the repositories forked, you will need to remove the jobs from the list
of jobs to run either from the Trigger job [configuration](home/jobs/Trigger/config.xml)
or directly from the Jenkins UI i.e. ``Trigger > Configure``.

# New jobs

It is recommended that new jobs should be defined using [Jenkinsfile pipelines](https://jenkins.io/doc/book/pipeline/jenkinsfile/) in the target repository as this makes it easier to maintain jobs.
Most Jenkins Pipeline jobs can share the same configuration apart from the repository URL.
If you do not require any special configuration use the [`TEMPLATE-pipeline-job-config.xml`](TEMPLATE-pipeline-job-config.xml) template by adding the job and parameters to [`pipeline-configs.yaml`](pipeline-configs.yaml).
Supported parameters are documented in that file.

The `rename.py` script will create the required job configurations from `pipeline-configs.yaml` as well as performing the renaming steps.
If for some reason you want to create the new job without running `rename.py` you can just run `createpipelinejobs.py`.

Alternatively create a new job in the Jenkins web-interface in the usual way.

# Default packages used

| Name       | Version       | Optional                           |
| -----------|---------------| -----------------------------------|
| Java       | openJDK 1.8   | openJDK 1.8 devel, oracleJDK 1.8   |
| Python     | 2.7           | -                                  |
| Ice        | 3.6           | 3.5                                |
| PostgreSQL | 9.4           | https://hub.docker.com/_/postgres/ |
| Nginx      | 1.8           | -                                  |
| Redis      | latest        | https://hub.docker.com/_/redis/    |

# Troubleshooting

See [Troubleshooting](Troubleshooting.md)

# ADVANCE: extend omero-install

In order to install additional components or new version of packages e.g. PostgreSQL 10, it is required to:

* Modify the files in [omero-install](https://github.com/ome/omero-install)
* Create a new image of [devslave-c7-docker](https://github.com/openmicroscopy/devslave-c7-docker) using the updated omero-install files
* Push the new image to [Docker Hub](https://hub.docker.com/). You will need to your own account
* Modify each Dockerfile of this repository to use the new image


# Upgrade

See [Changelog](CHANGELOG.md)
