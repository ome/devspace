
Getting started
---------------

 * Clone devspave to a directory with a meaningful name,
   since this will be part of your docker container names:

   git clone git://github.com/openmicroscopy/devspace MYTOPIC

 * Run rename.py to match your topic name:

   ./rename.py MYTOPIC

 * Optionally, commit those changes to a new branch

 * Configure the .ssh and .gitconfig files in the slave directory (TBD)

 * Configure artifactory:
   - Add an artifactory user (optional)
   - Under "System Configuration" add your artifactory URL
