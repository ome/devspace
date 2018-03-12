# Getting started

Devspace is a Continuous Integration tool managed by [Jenkins CI](https://jenkins.io/) providing
an automation framework that runs repeated jobs. The default deployment
initializes a Jenkins CI master with a predefined set of jobs.


Running and maintaining Devspace requires brief understanding of:

*  [Docker engine](https://docs.docker.com/)
*  [Docker compose](https://docs.docker.com/compose/)

Running and maintaining Devspace in OpenStack requires, in addition, brief understanding of:

* [Ansible](http://docs.ansible.com/ansible/intro_getting_started.html)
    *  [playbook](http://docs.ansible.com/ansible/playbooks.html)
*  access to openstack tenancy

Running Devspace requires access to SSH and Git configuration files used for fetching and pushing the Git repositories.

Devspace code depends on the following repositories:

* [OMERO install](https://github.com/ome/omero-install/)
* [devslave-c7-docker](https://github.com/openmicroscopy/devslave-c7-docker) 

and for OpenStack (optional)

* [ansible-role-devspace](https://github.com/openmicroscopy/ansible-role-devspace)

# Installation

You can either deploy manually a devspace on a Docker host or you can use the [Ansible playbooks](http://docs.ansible.com/ansible/playbooks.html) to deploy a devspace on [OpenStack](https://www.openstack.org/).

## Deploy on a Docker host

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
    your own SSH and Git configuration files

 *  Run `rename.py` to match your topic name. Specify the Git user corresponding to
    the confguration files used above. If you do not yet have
    topic branches available on origin, use "develop" or one of the
    main branches:

        $ ./rename.py MYTOPIC --user git_user

*   This will also replace the `USER_ID` of the various Dockerfile with the ID of the user who
    will run the devspace, assumed to be: `id -u`, i.e. the current user.

*   Set environment variables in `.env`, especially:

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


## Deploy on OpenStack

The following instructions explain how to deploy a devspace on OpenStack.
First, you will need to have an account on [OME OpenStack](https://pony.openmicroscopy.org).

The SSH and Git configuration files are used for fetching from and pushing to the Git repositories. They will be copied to the devspace.

The OpenStack and SSH and Git following steps are only need to be done the first time you generate instances.

#### OpenStack configuration

* Log into [OpenStack](https://pony.openmicroscopy.org)
* Register a key: 
   * Go to the ``Access & Security`` tab 
   * Click on ``Key Pairs`` and then on ``Import Key Pair``
   * Copy the content of the public key you use to access our resources e.g. ``id_rsa.pub``
   * The name you used is referred below as ``your_openstack_key``
* Download your configuration:
   * Go to the ``Access & Security`` tab
   * Then ``API Access``
   * Click on ``Download OpenStack RC File v2.0``
   * The file will be named by default ``omedev-openrc.sh``. It will be used to set environment variables needed to connect to OpenStack via the command line.

#### SSH and Git configuration files

In order to be able to push result of the build job to your GitHub account, you will need a SSH key **without passphrase**. The key must be named ``id_gh_rsa``.
The key and the configuration files will be copied to the devspace.

* Create a directory ``devspace_config`` where you wish and a directory ``devspace_config/.ssh``

* Generate a SSH key **without passphrase** in ``devspace_config/.ssh`` directory:

        $ ssh-keygen -t rsa -b 4096 -C "your_email_address" -f path/to/devspace_config/.ssh/id_gh_rsa -q -P ""

* Upload the corresponding public key i.e. ``id_gh_rsa.pub`` to your GitHub account

* Create a file ``devspace_config/.ssh/config`` and add the following:

        Host github.com
            User git
            IdentityFile ~/.ssh/id_gh_rsa

* Create a ``devspace_config/.gitconfig`` file

* Generate a [GitHub token](https://github.com/settings/tokens) and add it to ``devspace_config/.gitconfig``. Minimally the file should contain:

        [github]
                token = your_token
                user = your_github_username
        [user]
                email = your_email_address
                name = your_real_name

* The ``devspace_config`` directory should look like:

```
/path/to/devspace_config/
   .gitconfig
   .ssh/
        config
        id_gh_rsa
        id_gh_rsa.pub
```

#### Create and provision the devspace

* Clone the ``devspace`` Git repository:

        $ git clone https://github.com/openmicroscopy/devspace.git

* Create a virtual environment and from the ``devspace`` directory, install ``shade`` to access OpenStack via the command line and ``Ansible``:

        $ virtualenv ~/dev
        $ . ~/dev/bin/activate
        $ cd devspace
        (dev) $ pip install -r requirements.txt

* Source the OpenStack configuration file to set the environments variables allowing connection to OpenStack via the command line, adjust to your local configuration:

        (dev) $ . path/to/omedev-openrc.sh
        Enter your password

The following commands need to be executed from the ``ansible`` subdirectory.

* Install the various ansible roles from the [Galaxy website](https://galaxy.ansible.com/):

        (dev) $ cd ansible
        (dev) $ ansible-galaxy install -r requirements.yml

To "upgrade" roles, you may want to specify ``--force`` when installing the roles.

* Create an instance on [OpenStack](https://pony.openmicroscopy.org) using the playbook ``create-devspace.yml``. It is recommended to prefix the name of the devspace by your name or your initals:

        (dev) $ ansible-playbook create-devspace.yml -e vm_name=your_name-devspace-name -e vm_key_name=your_openstack_key

By default the size of the volume is ``50``GiB, if you required a larger size, it can be set by passing for example `-e vm_size=100`.
The Floating IP of the generated instance is referred as ``devspace_openstack_ip`` below.

* To provision the devpace, use the playbook ``provision-devspace.yml``. Before running
the playbook you will minimally **need to edit** the value of the parameter:
   * ``configuration_dir_path``: set it to ``path/to/devspace_config``

See [ansible-role-devspace](https://github.com/openmicroscopy/ansible-role-devspace) for a full list of supported parameters. Provision the devspace by running:

        (dev) $ ansible-playbook -u centos -i devspace_openstack_ip, provision-devspace.yml

### Access the devspace and determine ports

Ports to access the various services are dynamically assigned. You will have to log in to the devspace as the ``omero`` user to determine the port used by a given service using your usual ssh key and not the ``id_gh_rsa`` key:

        ssh omero@devspace_openstack_ip
        cd devspace

* The port to access the Jenkins UI is obtained by running:

        docker-compose port nginxjenkins 443

    * The output of the command looks like:

            WARNING: The JENKINS_PASSWORD variable is not set. Defaulting to a blank string.
            WARNING: The USER_ID variable is not set. Defaulting to a blank string.
            0.0.0.0:xxxx

        where ``xxxx`` is the assigned port ``$JENKINS_PORT``

    * The Jenkins UI will be available at:

            https://devspace_openstack_ip:$JENKINS_PORT


* The port to access OMERO.web is obtained by running:

       docker-compose port nginx 80 

    * The command will generate a similar output that the one above

            WARNING: The JENKINS_PASSWORD variable is not set. Defaulting to a blank string.
            WARNING: The USER_ID variable is not set. Defaulting to a blank string.
            0.0.0.0:xxxx

        where ``xxxx`` is the assigned port ``$WEB_PORT`` 

    * OMERO.web will be available at

            http://devspace_openstack_ip:$WEB_PORT/web 


* The port to access OMERO.insight or OMERO.cli is obtained by running:

       docker-compose port omero 4064 

    * The command will generate a similar output that the one above

            WARNING: The JENKINS_PASSWORD variable is not set. Defaulting to a blank string.
            WARNING: The USER_ID variable is not set. Defaulting to a blank string.
            0.0.0.0:xxxx

        where ``xxxx`` is the assigned port ``$SERVER_PORT`` 

    * To login either via OMERO.insight or OMERO.cli use ``$SERVER_PORT`` as the port value
and ``devspace_openstack_ip`` as the server value. You **must** use the secure connection.


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
| BIOFORMATS-ant         | testintegration | Builds Bio-Formats and runs unit tests    | devspace_testintegration_1 |
| BIOFORMATS-maven       | testintegration | Builds Bio-Formats and runs unit tests    | devspace_testintegration_1 |
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
