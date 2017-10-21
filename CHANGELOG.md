
 *  Upgrade to 0.3.0:

    - Devspace should be run in VM.
    - Services are managed by ansible playbook run with inline v1 compose

    - It is possible to extend services using ansible playbook. If you already created new containers based on existing Dockerfiles, you may wish to review your customization and extend common services

 *  Upgrade to 0.2.0:

    If you made custom adjustments to the code and committed them, it is recommended to reset changes.

    Here are listed the most important changes:

     * Compose configuration was split into a few different files depending on the platform

            - docker-compose.yml main file
            - docker-compose.unixports.yml required for running container on UNIX platform
            - docker-compose.osx.yml required for running containers on OSX platform

       For how to run check deployment

     * All nodes are now systemd nodes that require adjusting the permissions. For what to change
       see deployment.

            - **Do not change Dockerfile** as this will load your USERID automatically
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