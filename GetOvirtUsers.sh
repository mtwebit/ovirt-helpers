#!/bin/bash
# Shell script to get ovirt user data from the engine database
# Created by Tamas Meszaros <mt+git@webit.hu>
# License: Apache 2.0
#
# To quickly grab a fresh copy of this file
# curl -Os https://raw.githubusercontent.com/mtwebit/ovirt-helpers/master/GetOvirtUsers.sh && chmod 700 GetOvirtUsers.sh
#

ovirt_database=engine

if [ ! -x /usr/bin/ovirt-shell ]; then
  echo "ERROR: Ovirt-shell not found. Is this the oVirt engine host?"
  exit 2
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
    echo "$0 [-h|--help] [-u|--uid <uid>] [-n|--name <username>] [-d|--database <dbname>]"
    exit
    ;;

    -u|--uid)
    ovirt_uid=$2
    shift
    ;;

    -n|--uname)
    ovirt_uname=$2
    shift
    ;;

    -d|--database)
    ovirt_database=$2
    shift
    ;;

  esac
shift
done


if [ "${ovirt_uid}${ovirt_uname}" == "" ]; then
  psql -qtA -d $ovirt_database -c "SELECT user_id,username from users;"
else
  if [ "${ovirt_uname}" != "" ]; then
    psql -qtA -d $ovirt_database -c "SELECT user_id from users WHERE username='$ovirt_uname';"
  fi
  if [ "${ovirt_uid}" != "" ]; then
    psql -qtA -d $ovirt_database -c "SELECT username from users WHERE user_id='$ovirt_uid';"
  fi
fi
