#!/bin/bash
# Shell script to update packages in an oVirt self-hosted system
# Created by Tamas Meszaros <mt+git@webit.hu>
# License: Apache 2.0
#
# To quickly grab a fresh copy of this file
# curl -Os https://raw.githubusercontent.com/mtwebit/ovirt-helpers/master/UpdateOvirtHosts.sh && chmod 700 UpdateOvirtHosts.sh
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

echo "*** Updating ovirt self-hosted engine setups. ***"

echo "Checking requirements..."

if [ ! -x /usr/bin/ovirt-shell ]; then
  echo "ERROR: Ovirt-shell not found. Is this the manager host?"
  exit 2
fi

/usr/bin/engine-upgrade-check -q || echo "No upgrade available." && exit 2

which BackupOvirt.sh || echo "ERROR: BackupOvirt.sh not found. Grab it from github.com/mtwebit." && exit 2

# yum loves to translate stuff
export LC_ALL=C
echo -n "Current Ovirt Engine "
yum info installed ovirt-engine-setup|grep ^Version
echo -n "Available Ovirt Engine "
yum info available ovirt-engine-setup|grep ^Version

echo "Please, check the upgrade notes on http://ovirt.org"

host1=vmserver3
ask host1 "Hostname where the engine vm runs" $host1

echo "Moving to global maintenance..."
ssh $host1 hosted-engine --set-maintenance --mode=global

echo "Performing Engine backup..."
./BackupOvirt.sh

echo "Updating Engine..."
yum update "ovirt-*-setup*"

ask pp "Press enter to start engine setup"
engine-setup

echo "Leaving global maintenance..."
ssh $host1 hosted-engine --set-maintenance --mode=none

echo "Upgrading the host where the engine vm runs..."
ssh $host1 hosted-engine --set-maintenance --mode=local
ssh $host1 yum -y update
ssh $host1 hosted-engine --set-maintenance --mode=none

echo "You can reboot $host1 after you close this connection to the engine host."

echo "You can upgrade ovirt hosts from the admin interface."
