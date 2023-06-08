This file contains a collection of tips

## Common problem when provisioning the devspace

If you have previously used the ``devspace_openstack_ip``, the above command might fail with the message
```
...
host key for 10.0.51.xxx has changed and you have requested strict checking.\r\nHost key verification failed.\r\n", "unreachable": true}
```

To fix the issue, remove the entry from ``~/.ssh/known_hosts`` and run the playbook again.

## Trigger failure: script not approved

The following error can occur:
```
org.jenkinsci.plugins.scriptsecurity.scripts.UnapprovedUsageException: script not yet approved for use
    at org.jenkinsci.plugins.scriptsecurity.scripts.ScriptApproval.using(ScriptApproval.java:459)
    at org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition.create(CpsFlowDefinition.java:109)
```

To fix the issue, go to ``Trigger > Configure`` and select ``Use Groovy Sandbox``

## Bio-Formats or OMERO-push failure

When the latest Java 8 version is not used, the following error will occur:

```
Installing JDK jdk-8u121-oth-JPR
Downloading JDK from http://download.oracle.com/otn/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz
Oracle now requires Oracle account to download previous versions of JDK. Please specify your Oracle account username/password.
ERROR: Unable to install JDK unless a valid Oracle account username/password is provided in the system configuration.
Finished: FAILURE
```

To fix the issue:

 * Click on ``Manage Jenkins > Global Tool Configuration``
 * Click on ``JDK installations...``
 * Select the latest JDK 8 using the selection box

## Access the OMERO.server logs

 * Log in:``ssh omero@devspace_openstack_ip``
 * Access the docker container ``docker exec -ti devspace_omero_1 bash``
 * Logs are under ``/home/omero/workspace/OMERO-server/OMERO.server/var/log``

## Copy the OMERO.server logs to your local machine

  * Log in:``ssh omero@devspace_openstack_ip``
  * Copy the logs from the container

      docker cp devspace_omero_1:/home/omero/workspace/OMERO-server/OMERO.server/var/log .

  * Copy the logs to your machine

      scp -Cr omero@devspace_openstack_ip:/home/omero/log /local/path/for/log
 
## Access test-integration logs

   * Follow the same steps as above using the container ``devspace_testintegration_1``
   * Logs are under ``/home/omero/workspace/OMERO-test-integration/src/dist/var/log``    

## Update scripts

By default the OMERO-push job does not merge the open PRs of [ome/scripts](https://github.com/ome/scripts).
If you need to use non-released version of the scripts you will need to:

 * Fork the [ome/scripts](https://github.com/ome/scripts) repository
 * Edit the merge command of the OMERO-push job and replace ``--shallow`` by ``--update-gitmodules``

## Give others acces to the devspace

* Log in ``ssh omero@devspace_openstack_ip``
* Open ``.ssh/authorized_keys`` and add the key(s)

## Configure Push jobs

Both BioFormats-push and OMERO-push can be modified to only merge the desired PR
Below is an example on how to only include PRs opened against [ome/openmicroscopy](https://github.com/ome/openmicroscopy) with ``--training`` in their description

 * Click on ``OMERO-push > Configure``
 * Go to ``MERGE_COMMAND`` and enter

	merge develop -Dnone -Itraining --no-ask --reset --shallow

## GitHub access

Due to Recent change in [RSA SSH host key](https://github.blog/2023-03-23-we-updated-our-rsa-ssh-host-key/)

In a terminal, Run:

``
mv ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
ssh -T git@github.com
``
