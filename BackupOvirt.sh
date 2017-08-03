#!/bin/bash
# Shell script to backup ovirt engine data
# Created by Tamas Meszaros <mt+git@webit.hu>
# License: Apache 2.0
#
# To quickly grab a fresh copy of this file
# curl -Os https://raw.githubusercontent.com/mtwebit/ovirt-helpers/master/BackupOvirt.sh && chmod 700 BackupOvirt.sh
#

# Ask a question and provide a default answer
# Sets the variable to the answer or the default value
# 1:varname 2:question 3:default value
function ask() {
  echo -n "${2} [$3]: "
  read pp
  if [ "$pp" == "" ]; then
    export ${1}="${3}"
  else
    export ${1}="${pp}"
  fi
}

# Ask a yes/no question, returns true on answering y
# 1:question 2:default answer
function askif() {
  ask ypp "$1" "$2"
  [ "$ypp" == "y" ]
}

echo "*** oVirt engine backup ***"

echo "Checking requirements..."
if [ ! -x /usr/bin/engine-backup ]; then
  echo "ERROR: engine-backup not found. Is this the manager host?"
  exit 2
fi

base_dir=~/ovirt-backup
ask base_dir "Base directory for storing backups" $base_dir

backup_dir=${base_dir}/`date +'%Y%m%d-%H%M'`
ask backup_dir "Directory to store this backup" $backup_dir

if [ -d "$backup_dir" ]; then
  echo $backup_dir exists. Remove it first if not needed.
  exit 2
fi

mkdir -p $backup_dir
cd $backup_dir

/usr/bin/engine-backup --mode=backup --file=engine-backup --log=engine-backup.log
