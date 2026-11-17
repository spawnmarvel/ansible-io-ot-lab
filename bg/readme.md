# BG

## Table of content

- [BG](#bg)
  - [Table of content](#table-of-content)
  - [bg](#bg-1)
  - [bg 1deploy\_mysql.yml information on multiple deploy](#bg-1deploy_mysqlyml-information-on-multiple-deploy)
  - [bg2](#bg2)


## bg

Things that we need to investgate and test is marked with bg and a number.

In Bg we do the job manually, understand the case and document, then apply automation with playbooks.

## bg 1deploy_mysql.yml information on multiple deploy 

Sometimes a clean VM power cycle is all it takes to clear out lingering hypervisor-level disk locks, socket descriptors, or stale cache states.

```bash
azureuser@mysql01:~$ 
sudo chown root:root /data
sudo chmod 755 /data

# The namei output confirms that the parent /data directory permissions (drwxr-xr-x root root) are correct, granting the mysql user full traversal rights to reach /data/mysql.
azureuser@mysql01:~$ namei -l /data/mysql
f: /data/mysql
drwxr-xr-x root  root  /
drwxr-xr-x root  root  data
drwxr-x--- mysql mysql mysql

sudo systemctl reset-failed mysql
sudo systemctl start mysql

# Verification: Run sudo systemctl status mysql to confirm whether the status reports active (running)
sudo systemctl status mysql

```

Playbooks to make


* check_mysql_permission
* fix_mysql.yml

Lets try to investegate the above fix and create a playbook for it.

What is the real cause, it is permission denied after boot so it seems, but it does not happen everytime.

## bg2