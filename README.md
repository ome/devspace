# Getting started

Devspace is a Continuous Integration tools managed by Jenkins CI providing
an automation framework that runs repeated jobs. The default deployment
initializes a Jenkins CI master with a predefined set of jobs.


Running and maintaining Devspace require:
*   brief understanding of ansible http://docs.ansible.com/ansible/intro_getting_started.html
    *   inventory http://docs.ansible.com/ansible/intro_inventory.html
    *   playbook http://docs.ansible.com/ansible/playbooks.html
*   access to openstack tenancy
*   own ssh key set in openstack tenancy, that name will be used as `vm_key_name`
*   openrc.sh http://docs.openstack.org/user-guide/common/cli-set-environment-variables-using-openstack-rc.html
*   snoopy ssh key and gitconfig


## Requirements

The following prerequisites are required for deploying a Jenkins devspace:

Client machine:
*   Ansible 2.1+
*   Shade

Create virtualenv:

    $ virtualenv dev
    $ source dev/bin/activate
    (dev) $ pip install ansible
    (dev) $ pip install shade

Clone infrastrucutre repository where all ansible playbooks and roles are

    (dev) $ git clone https://github.com/openmicroscopy/infrastructure.git
    (dev) $ cd infrastracture/ansible

## Deployment

Ansible playbooks are available in https://github.com/openmicroscopy/infrastructure/tree/devspace/ansible

 * It is recommended to use devspace playbook to install devspace on a Virtual Machine like OpenStack
 
 * create new vm
 
        (dev) $ source path/to/openrc.sh
        # vm_key_name is a name of ssh key in openstack
        # vm_size (default 50GB) is a size of the volume vm boot from. You no longer have to attach additional volumes!
        (dev) $ ansible-playbook os-devspace.yml -e vm_name=my-devspace -e vm_key_name=mysshkey

    NOTE: VM will boot from volume, you no longer have to attach additional volumes. Size of the volume can be set by `-e vm_size=100`

 *  create inventory
 
        $ tree /path/to/inventory
        devspace
          ├── devspace-hosts
          ├── group_vars
          │   └── devspace
          └── snoopy
              ├── .gitconfig
              └── .ssh


        /path/to/inventory/devspace/group_vars/devspace

        openstack_ip: 10.0.50.100
        omero_branch: develop
        snoopy_dir_path: "/path/to/ssh_keys/"

        /path/to/inventory/devspace/devspace-hosts

        [devspace]
        10.0.50.100

   NOTE:

    `omero_branch` is a name of git branch all the jobs will be using. By default it is using `https://github.com/openmicroscopy/openmicroscopy/tree/develop`.
    If you wish to use your own fork please adjust jobs manually.

 *  ssh keys in ``/path/to/inventory/devspace/snoopy/.ssh`` that includes:

        -rwx------.  1    74 Sep 13 15:25 config
        -rwx------.  1  1674 Sep 13 15:25 snoopycrimecop_github
        -rwx------.  1   405 Sep 13 15:25 snoopycrimecop_github.pub

 *  install prerequisites as default user with sudo privileges (as user `centos`)
 
        ansible-playbook -i /path/to/inventory/devspace -u centos devspace.yml

 *  run containers (as user `omero`)
 
        ansible-playbook -i /path/to/inventory/devspace -u omero devspace-runtime.yml

   NOTE:

    `devspace-runtime.yml` is a basic playbook to start containers.
    If you wish to have a full control on which containers are run write your own playbook and managed containers directly from palybook.
    For more complex deployment follow https://docs.ansible.com/ansible/docker_service_module.html

## Multiply containers

 *  common-services.yml contains default list of basic containers that are suitable to extend:
    You can extend any service together with other configuration keys. For more details
    read https://docs.docker.com/v1.6/compose/extends/

 * to override the basic containers keep in mind compose copies configurations from the
   original service over to the local one, except for links and volumes_from.

   Examples of how to extend existing containers.

    - baseomero: basic container starting OMERO.server process

            myomero:
                extends:
                    file: common-services.yml
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

    **NOTE: you have to create manually all new volume directories to avoid 
    automatic creation as root**

    Copy existing job and point to the right host

## Job workflow


The default deployment initializes a Jenkins server with a [predefined set of
jobs](homes/jobs). The table below lists the job names, the Jenkins node labels
they are associated with and a short description of the job:

| Job name               | Name            | Description                               |
| -----------------------|-----------------| ------------------------------------------|
| Trigger                |                 | Runs all the following jobs in order      |
| BIOFORMATS-push        | testintegration | Merges all Bio-Formats PRs                |
| BIOFORMATS-ant         | bf              | Builds Bio-Formats and runs unit tests    |
| BIOFORMATS-maven       | testintegration | Builds Bio-Formats and runs unit tests    |
| OMERO-push             | testintegration | Merges all OMERO PRs                      |
| OMERO-build            | testintegration | Builds OMERO artifacts (server, clients)  |
| OMERO-server           | omero           | Deploys an OMERO.server                   |
| OMERO-web              | web             | Deploys an OMERO.web client               |
| OMERO-test-integration | testintegration | Runs the OMERO integration tests          |
| OMERO-robot            | testintegration | Runs the Robot test                       |
| nginx                  | nginx           | Reloads the nginx server                  |


Default packages:

| Name       | Version       | Optional                           |
| -----------|---------------| -----------------------------------|
| Java       | openJDK 1.8   | openJDK 1.8 devel, oracleJDK 1.8   |
| Python     | 2.7           | -                                  |
| Ice        | 3.6           | 3.5                                |
| PostgreSQL | latest        | https://hub.docker.com/_/postgres/ |
| Nginx      | 1.8           | -                                  |
| Redis      | latest        | https://hub.docker.com/_/redis/    |


## Customization:

* Updating omero-install scripts:

In order to install additional components it is required to first adjust omero-install repository https://github.com/ome/omero-install
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

## Limitations:

* Robot job is still under investigation as it fails due to webbrowser crash. Robot job requires manual changes of the domain. Make sure webhost is set to the correct VM IP

        --webhost "10.0.50.100"

## Upgrade

 *  Upgrade to 0.3.0:

    - Devspace should be run in VM.
    - Services are managed by ansible playbook run with inline v1 compose

    - It is possible to extend services using ansible playbook. If you already created new containers based on existing Dockerfiles, you may wish to review your customisation and extend common services

 *  Upgrade to 0.2.0:

    If you made custom adjustments to the code and commited them, it is recommended to reset changes.

    Here are listed the most important changes:

     * Compose configuration was split into a few different files depending on the platform

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

