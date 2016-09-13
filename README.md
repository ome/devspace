# Getting started

Devspace is a Continuous Integration tools managed by Jenkins CI providing
an automation framework that runs repeated jobs. The default deployment
initializes a Jenkins CI master with a predefined set of jobs.

## Requirements

The following prerequisites are required for deploying a Jenkins devspace:

Remot host:
*   Docker Engine 1.10 or later
*   Docker Compose 1.7.0
*   PIP 1.8+

Client:
*   Ansible 2.1+
*   Shade

On the client create virtualenv:

    virtualenv dev
    source dev/bin/activate
    pip install ansible
    pip install shade

## Deployment

Ansible playbooks are available in https://github.com/openmicroscopy/infrastructure/tree/devspace/ansible

 * It is recomanded to use devspae playbook to install devspace on a Virtual Machine like OpenStack
 
 * create new vm
 
        ansible-playbook os-devspace.yml -e vm_name=my-devspace -e vm_key_name=ola

 *  create inventory
 
        /path/to/ansible/devspace/group_vars/devspace

        docker_use_ipv4_nic_mtu: True
        devuser: omero
        user_id: "1001"
        devhome: /home/{{ devuser }}/devspace
        openstack_ip: 10.0.50.100
        omero_branch: develop
        snoopy_dir_path: "/path/to/ssh_keys/"
        git_repo: "https://github.com/openmicroscopy/devspace.git"
        version: "master"

        /path/to/ansible/devspace/devspace-hosts

        [devspace]
        10.0.50.100

   NOTE:

    omero_branch is a name of git branch all the jobs will be using. By default it is using git://openmicroscopy/develop.
    If you wish to use your own fork please adjust jobs manually.

 *  ssh keys
 
        /path/to/ansible/devspace/snoopy/.ssh
        /path/to/ansible/devspace/snoopy/.gitconfig

 *  install prerequisites as default user with sudo rights
 
        ansible-playbook -i /path/to/ansible/devspace -u centos devspace.yml

 *  run containers (as user omero)
 
        ansible-playbook -i /path/to/ansible/devspace -u omero devspace-runtime.yml


## Multiply containers

 *  common-services.yml contains default list of basic contaners are suitable to extend:
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
| -----------|---------------| -----------------------------------|
| Java       | openJDK 1.8   | openJDK 1.8 devel, oracleJDK 1.8   |
| Python     | 2.7           | -                                  |
| Ice        | 3.6           | 3.5                                |
| PostgreSQL | latest        | https://hub.docker.com/_/postgres/ |
| Nginx      | 1.8           | -                                  |
| Redis      | latest        | https://hub.docker.com/_/redis/    |
| -----------|---------------| -----------------------------------|

## Upgrade

 *  Uprade to 0.3.0:

    - Devspace should be run in VM.
    - Services are managed by ansible playbook run with inline v1 compose

    - It is possible to extend services using ansible playbook. If you already created new containers based on existing Dockerfiles, you may wish to review your customisation and extend common services

 *  Uprade to 0.2.0:

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

