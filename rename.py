#!/usr/bin/python

import argparse
import fileinput
import fnmatch
import os
import re
import createpipelinejobs


EXCLUDE = ["builds", "workspace", "fingerprints"]

def replace(name, branch, uid, user):
  cnt = 0
  for root, dirs, files in os.walk("."):
    dirs[:] = list(filter(lambda x: not x in EXCLUDE, dirs))
    env = list(fnmatch.filter(files, ".env"))
    yml = list(fnmatch.filter(files, "*.yml"))
    xml = list(fnmatch.filter(files, "*.xml"))
    sh = list(fnmatch.filter(files, "sslcert.sh"))
    docker = list(fnmatch.filter(files, "Dockerfile"))
    for f in env + yml + xml + sh + docker:
      fname = os.path.join(root, f)
      print "Setting space to '%s', %s' in %s" % (name, user, fname)
      for line in fileinput.input([fname], inplace=True):
        regexp = re.compile(r'(SPACE[NAME|BRANCH|USER]|1000)')
        if regexp.search(line) is not None:
          cnt += 1
          line = line.replace("SPACENAME", name)
          line = line.replace("SPACEBRANCH", name)
          line = line.replace("SPACEUSER", user)
          line = line.replace("1000", str(uid))
        print line,
  return cnt

if __name__ == "__main__":
  if os.path.exists('pipeline-configs.yaml'):
      createpipelinejobs.main()
  parser = argparse.ArgumentParser()
  parser.add_argument("--uid", type=int, default=os.getuid())
  parser.add_argument("name")
  parser.add_argument("branch", nargs="?")
  parser.add_argument("--user", nargs="?")
  ns = parser.parse_args()
  name = ns.name
  branch = ns.branch
  user = ns.user
  if not branch:
    branch = name
  if not user:
    user = "snoopycrimecop"
  replace(name, branch, ns.uid, user)
  print "Done. You may want to review and commit your changes now"
