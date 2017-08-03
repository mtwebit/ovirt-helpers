#!/bin/bash
# Shell script to get data about virtual machines from the engine database
# Created by Tamas Meszaros <mt+git@webit.hu>
# License: Apache 2.0
#
# To quickly grab a fresh copy of this file
# curl -Os https://raw.githubusercontent.com/mtwebit/ovirt-helpers/master/GetOvirtVms.sh && chmod 700 GetOvirtVms.sh
#

ovirt_database=engine

if [ ! -x /usr/bin/ovirt-shell ]; then
  echo "ERROR: Ovirt-shell not found. Is this the oVirt engine host?"
  exit 2
fi

which GetOvirtUsers.sh || echo "ERROR: GetOvirtUsers.sh not found. Grab it from github.com/mtwebit/." && exit 2

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
    echo "$0 [-h|--help] [-u|--uid <uid>] [-n|--name <username>] [-s|--status <0|1>] [-a|--all] [-U|--by-user] [-d|--database <dbname>]"
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

    -s|--status)
    vm_status=$2
    if [ "$vm_status" == "running" ]; then vm_status=1; fi
    if [ "$vm_status" == "stopped" ]; then vm_status=0; fi
    shift
    ;;

    -a|--all)
    ;;

    -U|--by-user)
    shift
    ovirt_users=$(./GetOvirtUsers.sh | cut -d "|" -f 2)
    for i in $ovirt_users; do $0 -n $i $*; done
    exit
    ;;

  esac
shift
done


what="vm_name,created_by_user_id,status"
where=""

if [ "${ovirt_uname}" != "" ]; then
  #what=$(echo $what|sed 's/,created_by_user_id//')
  user_id=$(./GetOvirtUsers.sh --uname $ovirt_uname)
  [[ "$user_id" == "" ]] && echo "$0 ERROR: unknown user: $ovirt_uname" && exit 1
  where="created_by_user_id='$user_id'"
fi

if [ "${ovirt_uid}" != "" ]; then
  #what=$(echo $what|sed 's/,created_by_user_id//')
  [[ "$where" == "" ]] && where="status='$vm_status'" || where="$where AND status='$vm_status'"
  where="created_by_user_id='$ovirt_uid'"
fi

if [ "${vm_status}" != "" ]; then
  #what=echo $what|sed 's/,status//'
  [[ "$where" == "" ]] && where="status='$vm_status'" || where="$where AND status='$vm_status'"
fi


[[ "$where" != "" ]] && where="WHERE $where"

list=$(psql -qtA -d $ovirt_database -c "SELECT $what FROM vms $where;")

for i in $list; do
  vm_name=$(echo $i|cut -d '|' -f 1)
  vm_owner_id=$(echo $i|cut -d '|' -f 2)
  if [ "$vm_owner_id" == "" ]; then continue; fi
  vm_owner=$(./GetOvirtUsers.sh --uid $vm_owner_id)
  vm_status=$(echo $i|cut -d '|' -f 3)

  printf "%20s %10s" "${vm_name}" "${vm_owner}"
  [[ "${vm_status}" == "1" ]] && echo " running" || echo ""
done
