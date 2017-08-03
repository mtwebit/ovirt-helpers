# ovirt-helpers
Helper scripts for oVirt

## BackupOvirt.sh - engine backup

## GetOvirtUsers.sh - get info about oVirt users (dumps uid and uname atm)
-d|--database - engine's database name
-u|--uid - get info about a user identified by his/her uid
-n|--uname - get info about a user identified by his/her uname

## GetOvirtVms.sh - get info about virtual machines
-d|--database - engine's database name
-u|--uid - filter by uid
-n|--uname - filter by uname
-s|--status - filter by status
-a|--all - display all vms (default)
-U|--by-user - sort by user

## UpdateOvirtHosts.sh - updating software in a self-hosted oVirt environment
Performs a step-by-step upgrade process for the engine and its host.
