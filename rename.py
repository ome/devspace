#!/usr/bin/python

import argparse
import fileinput
import fnmatch
import os
import re

EXCLUDE = ["builds", "workspace", "fingerprints"]

def replace(name, branch, uid, user):
  cnt = 0
  cnt_user = 0
  for root, dirs, files in os.walk("."):
    dirs[:] = list(filter(lambda x: not x in EXCLUDE, dirs))
    yml = list(fnmatch.filter(files, "*.yml"))
    xml = list(fnmatch.filter(files, "*.xml"))
    sh = list(fnmatch.filter(files, "sslcert.sh"))
    for f in yml + xml + sh:
      fname = os.path.join(root, f)
      print "Setting space to '%s' in %s" % (name, fname)
      for line in fileinput.input([fname], inplace=True):
        regexp = re.compile(r'SPACE[NAME|BRANCH]')
        regexp_user = re.compile(r'SPACEUSER')
        if regexp.search(line) is not None:
          cnt += 1
          line = line.replace("SPACENAME", name)
          line = line.replace("SPACEBRANCH", name)
        if regexp_user.search(line) is not None:
          cnt_user += 1
          line = line.replace("SPACEUSER", user)
        print line,
  return (cnt, cnt_user)

if __name__ == "__main__":
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
