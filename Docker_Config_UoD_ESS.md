UoD Deployment Note
===================
For deployments to UoD only, mount docker data root folder on ESS, use the followings instructions and update the docker configuration before deployment.

This configuration change is not required for deployments to other environments.

Instructions
------------

* Opens a terminal session as the root

      sudo su

* Create the virtual disk (40 GB, it can be increased it in the future if needed)

      dd if=/dev/zero of=/uod/idr/scratch/docker-storage.img bs=1G count= 40

* Format the disk

      mkfs.xfs /uod/idr/scratch/docker-storage.img

* Create a directory to act as a mount point and bind the virtual drive to it

      mkdir -p /var/lib/docker-xfs
      mount -o loop,pquota /uod/idr/scratch/docker-storage.img /var/lib/docker-xfs

* Mount the virtual disk when machine is restarted

      vi /etc/fstab

    Add this line by the end of the file

        /uod/idr/scratch/docker-storage.img /var/lib/docker-xfs xfs loop,defaults 0 0

* Check it

      df -h /var/lib/docker-xfs

* Stop the docker service
 
      systemctl stop docker
 
* Edit the following file to configure the docker to use the mounted folder for data root 

      vi /etc/docker/daemon.json

   Add the following contents 
    
        {
          "data-root": "/var/lib/docker-xfs",
          "storage-driver": "overlay2"
        }


* Start the docker service 

      systemctl start docker 


Restart Issue:
-------------

The restart issue on the VM: the machine restarts, but the containers do not restart with it.  

This has been investigated on the merge-ci host (**ome-devsp-ap1**), it occurred because the Docker image disk (**docker-storage_ap1.img**) was not properly mounted to **/var/lib/docker-xfs-ap1**. To resolve this, The **/etc/fstab** file has been updated so the mount depends on the scratch folder being available and retries every 30 seconds if it fails, i.e.:

    /uod/idr/scratch/docker-storage_ap1.img /var/lib/docker-xfs-ap1 xfs loop,defaults,x-systemd.requires-mounts-for=/uod/idr/scratch,,x-systemd.mount-timeout=30  0 0

The Docker service file has been updated so it relies on the mounted image disk. The following clause 

    [Unit]
    RequiresMountsFor=/var/lib/docker-xfs-ap1

has been added to this file:
    
    /etc/systemd/system/docker.service.d/override.conf

Following these adjustments, a system reboot successfully brought back all Docker containers. The identical fix should be deployed to the active merge-ci host (**idr3-slot2**).
