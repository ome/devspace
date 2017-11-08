# Getting started

Devspace is a Continuous Integration tool managed by Jenkins CI providing
an automation framework that runs repeated jobs. The default deployment
initializes a Jenkins CI master with a predefined set of jobs.


Running and maintaining Devspace requires brief understanding of:

*  [Docker engine](https://docs.docker.com/)
*  [Docker compose](https://docs.docker.com/compose/)

Running and maintaining Devspace in OpenStack requires, in addition, brief understanding of:

* [Ansible](http://docs.ansible.com/ansible/intro_getting_started.html)
    *  [playbook](http://docs.ansible.com/ansible/playbooks.html)
*  access to openstack tenancy
*  own ssh key set in openstack tenancy, that name will be used as `vm_key_name`
*  [openrc.sh](https://docs.openstack.org/zh_CN/user-guide/common/cli-set-environment-variables-using-openstack-rc.html)

Running Devspace requires access to SSH and Git configuration files used for fetching and pushing the Git repositories.

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

*   Replace the `USER_ID` of the various Dockerfile with the ID of the user who
    will run the devspace:

        $ find . -iname Dockerfile -type f -exec sed -i -e 's/1000/<USER_ID>/g' {} \;

    To find the `USER_ID`, use the id command i.e. ``id -u username``

*   Set the environment variables in `.env`:

        USER_ID=<USER_ID>
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

Your SSH and Git configuration files should be used for for fetching and pushing the Git repositories.

#### OpenStack configuration

The following steps only need to be done the first time you want to generate instances.

* Log into [OpenStack](https://pony.openmicroscopy.org)
* Register a key. Go to ``Access & Security > Key Pairs``
* Under ``Access & Security > API Access``, download your configuration by clicking on ``Download OpenStack RC File v2.0``. The file will be named by default ``omedev-openrc.sh``

#### SSH and Git configuration files

In order to be able to push result of the build job, you will need a SSH key **without passphrase**. 
The key must be named ``id_gh_rsa``.

* Generate a SSH key **without passphrase** in your ``.ssh`` directory:

        $ ssh-keygen -t rsa -b 4096 -C "your_email_address" -f ~/.ssh/id_gh_rsa -q -P ""

* Upload the public key i.e. ``id_gh_rsa.pub`` to your GitHub account

* Open ``.ssh/config`` and add the following:

        Host github.com
            User git
            IdentityFile ~/.ssh/id_gh_rsa

* Generate a [GitHub token](https://github.com/settings/tokens) and add it to ``~/.gitconfig``:

        [github]
                token = your_token

#### Create and provision the devspace

* Clone the ``devspace`` Git repository:

        $ git clone https://github.com/openmicroscopy/devspace.git

* Create a virtual environment and install the Ansible requirements (including ``shade`` for using with OpenStack):

        $ virtualenv ~/dev
        $ . ~/dev/bin/activate
        $ cd devspace
        (dev) $ pip install -r requirements.txt

* Source the OpenStack configuration file, adjust to your local configuration:

        (dev) $ . omedev-openrc.sh
        Enter your password

The following commands need to be executed from the ``ansible`` subdirectory.

* Install the various ansible roles:

        (dev) $ cd ansible
        (dev) $ ansible-galaxy install -r requirements.yml

* Create the devpace. It is recommended to prefix the name of the devspace by your name or your initals:

        (dev) $ ansible-playbook create-devspace.yml -e vm_name=your_name-devspace-name -e vm_key_name=your_key

By default the size of the volume is ``50``GiB, if you required a larger size, it can be set by passing for example `-e vm_size=100`.
The Floating IP of the generated instance is referred as ``devspace_openstack_ip`` below.

* To provision the devpace, you can use the example playbook ``provision-devspace.yml``. Before running
the playbook you will minimally need to set the value of the parameters ``configuration_dir_path`` and ``github_user``.
The ``configuration_dir_path`` should be the path to your ``.ssh`` directory usually ``~`` and ``github_user`` should be
your username on GitHub. 
See [ansible-role-devspace](https://github.com/openmicroscopy/ansible-role-devspace) for a full list of supported
parameters. Provision the devspace by running:

        (dev) $ ansible-playbook -u centos -i devspace_openstack_ip, provision-devspace.yml

If you have previously used the ``devspace_openstack_ip``, the above command might fail with the message ``Host key verification failed``. To fix the issue, remove the entry from ``~/.ssh/known_hosts`` and run the command again.

### Access the devspace

Ports to access the various services are dynamically assigned. You will have to log in to the devspace as the ``omero`` user to determine the port used by a given service:

        ssh omero@devspace_openstack_ip
        cd devspace

The port for each service is obtained by running:

       docker-compose port $SERVICE $PRIVATE_PORT

where $SERVICE $PRIVATE_PORT are described in the table below:

Service | Private port |  Command | Result
--------| ------|------------|----
nginxjenkins | 443 | https://devspace_openstack_ip:$PORT | Access to Jenkins UI
nginx | 80 | http://devspace_openstack_ip:$PORT/web  | Login via OMERO.web
omero | 4064 | Add `devspace_openstack_ip $PORT` as server  | Login via OMERO.insight



# ADVANCE: Multiply containers

 * List of devspace containers can be controlled by custom runtime handler in `devspace_handler_tasks`.
   For more complex deployment see [devspace-runtime.yml](https://github.com/openmicroscopy/ansible-role-devspace/blob/master/tasks/devspace-runtime.yml) that uses [docker service module](https://docs.ansible.com/ansible/docker_service_module.html).

 * [common-services-v1.yml](common-services-v1.yml) contains a default list of basic containers that are suitable to extend. You can extend any service together with other configuration keys. For more details
    read [extends](https://docs.docker.com/v1.6/compose/extends/).

 * to override the basic containers keep in mind compose copies configurations from the
   original service over to the local one, except for links and volumes_from.

   Examples of how to extend existing containers.

    - baseomero: basic container starting OMERO.server process

            myomero:
                extends:
                    file: common-services-v1.yml
                    service: baseserver
                links:
                    - jenkins
                    - pg
                volumes:
                    - ./myservices/omero:/home/omero
                environment:
                    - SLAVE_NAME=myomero
                ports:
                    - "24064:24064"
                    - "24063:24063"

    - baseweb: basic container starting OMERO.web process

            myweb:
                extends:
                    file: common-services-v1.yml
                    service: baseweb
                links:
                    - jenkins
                    - redis
                    - myomero
                volumes:
                    - ./myservices/web:/home/omero
                    - ./myservices/nginx/conf.d:/home/omero/nginx
                environment:
                    - SLAVE_NAME=myweb

    - basenginx: basic container starting nginx process

            mynginx:
                extends:
                    file: common-services-v1.yml
                    service: basenginx
                links:
                    - jenkins
                    - myweb
                volumes:
                    - ./myservices/nginx/conf.d:/etc/nginx/conf.d
                    - ./myservices/web/static:/home/omero/static
                environment:
                    - SLAVE_NAME=mynginx
                ports:
                    - "8080:80"

    NOTE:

    **You have to create manually all new volume directories to avoid 
    permission issues. Copy from appropriate existing jobs and point to the new node.**


# Job workflow


The default deployment initializes a Jenkins server with a [predefined set of
jobs](home/jobs). The table below lists the job names, the Jenkins node labels
they are associated with and a short description of the job:

| Job name               | Name            | Description                               |
| -----------------------|-----------------| ------------------------------------------|
| Trigger                |                 | Runs all the following jobs in order      |
| BIOFORMATS-push        | testintegration | Merges all Bio-Formats PRs                |
| BIOFORMATS-ant         | testintegration | Builds Bio-Formats and runs unit tests    |
| BIOFORMATS-maven       | testintegration | Builds Bio-Formats and runs unit tests    |
| OMERO-push             | testintegration | Merges all OMERO PRs                      |
| OMERO-build            | testintegration | Builds OMERO artifacts (server, clients)  |
| OMERO-server           | omero           | Deploys an OMERO.server                   |
| OMERO-web              | web             | Deploys an OMERO.web client               |
| OMERO-test-integration | testintegration | Runs the OMERO integration tests          |
| OMERO-robot            | testintegration | Runs the Robot tests                      |
| nginx                  | nginx           | Reloads the nginx server                  |
| OMERO-docs             | testintegration | Builds the OMERO documentation            |


Default packages:

| Name       | Version       | Optional                           |
| -----------|---------------| -----------------------------------|
| Java       | openJDK 1.8   | openJDK 1.8 devel, oracleJDK 1.8   |
| Python     | 2.7           | -                                  |
| Ice        | 3.6           | 3.5                                |
| PostgreSQL | latest        | https://hub.docker.com/_/postgres/ |
| Nginx      | 1.8           | -                                  |
| Redis      | latest        | https://hub.docker.com/_/redis/    |


# Customization

* Updating omero-install scripts:

In order to install additional components it is required to first adjust update files in [omero-install](https://github.com/ome/omero-install).
Then fetch custom omero-install branch by updating each Dockerfile

    ├── nginx
    │   ├── Dockerfile
    ├── server
    │   ├── Dockerfile
    ├── slave
    │   ├── Dockerfile
    └── web
        ├── Dockerfile


    ## update omero-install to use custom fork
    RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.email "you@example.com"
    RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT config --global user.name "Your Name"
    RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT remote add username https://github.com/username/omero-install.git
    RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT fetch username
    RUN git --git-dir=$OMERO_INSTALL_ROOT/.git --work-tree=$OMERO_INSTALL_ROOT merge username/yourbranch

## Limitations

* Robot job is still under investigation as it fails due to webbrowser crash. Robot job requires manual changes of the domain. Make sure webhost is set to the correct VM IP e.g.

        --webhost "10.0.50.100"


# Upgrade

See [Changelog](CHANGELOG.md)
