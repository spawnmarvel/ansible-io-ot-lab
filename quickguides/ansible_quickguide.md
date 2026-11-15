# Ansibel quickguide

## Table of content

- [Ansibel quickguide](#ansibel-quickguide)
  - [Table of content](#table-of-content)
  - [azure-ansibel quickguide back in 2023](#azure-ansibel-quickguide-back-in-2023)
  - [Ansible docs](#ansible-docs)
  - [Core Concepts](#core-concepts)
  - [Key Advantages](#key-advantages)
  - [Ansible Agentless Architecture Linux and Windows](#ansible-agentless-architecture-linux-and-windows)
  - [Essential Ansible concepts](#essential-ansible-concepts)
  - [Getting Started with Ansible: A Beginner’s Guide](#getting-started-with-ansible-a-beginners-guide)
  - [Inventory](#inventory)
  - [SSH key-based authentication](#ssh-key-based-authentication)
    - [host\_key\_checking ansible.cfg](#host_key_checking-ansiblecfg)
  - [Ansible Ad-hoc commands](#ansible-ad-hoc-commands)
  - [Sample Ansible setup](#sample-ansible-setup)
  - [Enable Native Logging](#enable-native-logging)
    - [OS-Level Auditing](#os-level-auditing)
    - [Get progress output, timestamps, and real-time visibility into long-running Ansible playbooks.](#get-progress-output-timestamps-and-real-time-visibility-into-long-running-ansible-playbooks)
    - [Verify yaml](#verify-yaml)
  - [Playbooks --check with --diff and or --limit and or --syntax-check and or --vvv](#playbooks---check-with---diff-and-or---limit-and-or---syntax-check-and-or---vvv)
  - [Semaphore UI](#semaphore-ui)
  - [10 habits of great Ansible users](#10-habits-of-great-ansible-users)
    - [8. Understand the serial keyword for rolling updates](#8-understand-the-serial-keyword-for-rolling-updates)
- [Playbook Keywords](#playbook-keywords)
- [Quickguide for IT OT LAB Basic 101](#quickguide-for-it-ot-lab-basic-101)
  - [ping\_hosts.yml](#ping_hostsyml)
  - [get\_linux\_version.yml](#get_linux_versionyml)
  - [configure\_apt\_proxy.yml](#configure_apt_proxyyml)
  - [verify\_firewall\_isolation.yml](#verify_firewall_isolationyml)
  - [update\_apt.yml](#update_aptyml)
  - [mount\_datadrive\_check.yml](#mount_datadrive_checkyml)
  - [mount\_datadrive\_for\_mysql\_azure.yml](#mount_datadrive_for_mysql_azureyml)
  - [mount\_datadrive\_for\_mysql\_generic\_hyperv.yml](#mount_datadrive_for_mysql_generic_hypervyml)
- [Quickguide for IT OT LAB Advanced 102](#quickguide-for-it-ot-lab-advanced-102)
  - [deploy\_mysql\_check.yml](#deploy_mysql_checkyml)
  - [deploy\_mysql.yml](#deploy_mysqlyml)

## azure-ansibel quickguide back in 2023

Testing and learning Ansibel with Azure

* Create vms linux and windows
* Playbook roles, When to turn a playbook into a role
* Semaphore UI
* mariadb, wordpress, apache, grafana etc
* Lots of gold here

* https://github.com/spawnmarvel/azure-ansible


## Ansible docs

https://docs.ansible.com/projects/ansible/latest/getting_started/index.html

## Core Concepts

* Control Node: The machine where Ansible is installed and commands are executed.

* Managed Nodes: The target servers, network devices, or VMs managed by Ansible.

* Inventory: A text file (INI or YAML) listing managed hosts grouped by environment or function.

* Playbook: A YAML file containing a sequence of plays and tasks that define the desired system state.

* Modules: Built-in Python scripts executed on targets to perform specific actions (e.g., package installation, file editing, service management).

* Roles: Modular, reusable directory structures for organizing playbooks, variables, and tasks.

## Key Advantages

* Agentless Architecture: Eliminates the need to maintain background daemons or agents on target systems.

* Declarative Language: Written in human-readable YAML focusing on what state the system should be in rather than how to achieve it.

* Idempotency: Tasks can run repeatedly without changing the system state if the desired outcome is already present.

## Ansible Agentless Architecture Linux and Windows

* On Linux, Ansible connects via SSH, authenticates using SSH keys or passwords, and transfers small Python modules to the /tmp directory on the target system. It executes those modules using the target's Python interpreter to apply the desired configuration, retrieves the JSON result, and automatically removes the temporary script files.

* On Windows, Ansible connects over WinRM (Windows Remote Management) or WinSSHD, authenticates using NTLM, Kerberos, or CredSSP, and executes PowerShell scripts or .NET code directly in memory. Results are captured in JSON format and returned to the control node without leaving persistent software behind.

## Essential Ansible concepts

https://developers.redhat.com/learning/learn:ansible:foundations-ansible/resource/resources:essential-ansible-concepts

## Getting Started with Ansible: A Beginner’s Guide

https://dev.to/anushree_gm/getting-started-with-ansible-a-beginners-guide-3deh

## Inventory

```bash
ssh espenk@192.168.10.70
mkdir mkdir io_ot_lab_build
```

## SSH key-based authentication

### host_key_checking ansible.cfg



## Ansible Ad-hoc commands

## Sample Ansible setup

* By default, if you have a roles/ folder sitting in the same directory as your playbook (e.g., playbook.yml and roles/my_role/), Ansible automatically finds and uses the roles there

This layout organizes most tasks in roles, with a single inventory file for each environment and a few playbooks in the top-level directory:

https://docs.ansible.com/projects/ansible/latest/tips_tricks/sample_setup.html

## Enable Native Logging

* Remove vars_prompt and shell appends: Keep your playbooks fully idempotent and automated.

* Enable Native Logging: If you want a local file log on the control node or managed nodes for debugging, configure Ansible's global callback or log output in ansible.cfg rather than writing manual tasks:

The file /opt/ansible/automation.log is located locally on the Ansible control node (ansiblectr01), not on the remote managed nodes (zabbix01, zabbix02, or mysql01).

If Ansible hasn't created the file yet, it is usually because the /opt/ansible directory does not exist or the executing user (master) lacks write permissions to /opt/ansible. You can create it and set ownership on the control node with:

```bash

sudo mkdir -p /opt/ansible
sudo chown master:master /opt/ansible

# run to confirm the directory exists and is owned by your user.
ls -ld /opt/ansible
```

```ini
[defaults]
log_path = /opt/ansible/automation.log
```

### OS-Level Auditing

OS-Level Auditing: For package installations and system modifications, Linux already maintains authoritative logs in /var/log/apt/history.log, /var/log/dpkg.log, and the system journal (journald), which can be collected by Zabbix or forwarded to a log aggregator (like Loki).


### Get progress output, timestamps, and real-time visibility into long-running Ansible playbooks.

Yes, you can easily get progress output, timestamps, and real-time visibility into long-running Ansible playbooks. When managing systems over network connections or executing time-consuming software updates and deployments, having visibility into task duration prevents terminal guessing and helps isolate bottlenecks.

1. Enable Native Task Timestamps (Community Callback Plugin)

```ini
[defaults]
callbacks_enabled = profile_tasks, timer
```

2. Print Timestamps via Custom Tasks or Debug Messages

If you want explicit timestamps printed in real time before or during long-running tasks (like large package upgrades or database indexing), you can use the ansible.builtin.debug module combined with the built-in ansible_date_time facts:

```yml
- name: Announce start of long running upgrade with timestamp
      ansible.builtin.debug:
        msg: "Starting package upgrade at {{ ansible_date_time.time }}"
```

### Verify yaml

https://www.yamllint.com/

## Playbooks --check with --diff and or --limit and or --syntax-check and or --vvv

Combine --check with --diff to see a before-and-after text comparison of any configuration files that would be modified:


```bash
ansible-playbook playbook.yml --check

ansible-playbook playbook.yml --check --diff
# To safely run a check or dry-run update across your nodes using Ansible limits, you can use Ansible's --check flag combined with --limit. This allows you to inspect what changes would occur without actually writing any packages to disk.
ansible-playbook -i inventory/hosts.ini playbooks/update_apt.yml --limit mysql01 --check

# when all works out on each one, you can run all or just one and one
ansible-playbook -i inventory/hosts.ini playbooks/update_apt.yml --limit mysql01

# syntax check, If the playbook has valid YAML formatting and correct Ansible structure, the command returns the playbook path and exits with return code 0
ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive.yml --syntax-check

# verbose
 ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive.yml --limit mysql01 --check -vvv
```

## Semaphore UI

Semaphore UI gives your team one self-hosted place to run, share, schedule, secure, and audit operational workflows.

Use Semaphore UI with Ansible, Terraform, OpenTofu, Terragrunt, Bash, PowerShell, and Python, while keeping your automation in Git and your existing toolchain intact.

* https://semaphoreui.com/


## 10 habits of great Ansible users

Whether you're writing playbooks, maintaining inventory, or executing tasks, here are 10 things to keep in mind as you implement enterprise-wide automation:

1. Use version control
2. Use whitespace and comments
3. Give variables unique and meaningful names
4. Use roles to keep playbooks well-organized
5. Troubleshoot on execution
6. Use block syntax
7. Use a separate inventory file for staging and production
### 8. Understand the serial keyword for rolling updates
9. Use native modules when possible
10. Keep debugging messages clean


https://www.redhat.com/en/blog/10-great-ansible-practices


# Playbook Keywords

These are the keywords available on common playbook objects. Keywords are one of several sources for configuring Ansible behavior. See Controlling how Ansible behaves: precedence rules for details on the relative precedence of each source.

https://docs.ansible.com/projects/ansible/latest/reference_appendices/playbooks_keywords.html

# Quickguide for IT OT LAB Basic 101

## ping_hosts.yml

Here we used ansible.builtin.ping

* https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/ping_module.html


## get_linux_version.yml

Here we used:

* ansible.builtin.command
* ansible.builtin.debug


We also used some new ansible keyword 

* register
* changed_when
* inventory_hostname (jinja2)

Ansible uses Jinja2 templating to enable dynamic expressions and access to variables and facts.

```yml
---
# Version: 1.1.1
# Author: aspen
# Description: Gathers and displays Linux distribution, release version, and kernel details using modern ansible_facts syntax.

- name: Gather and Display Linux Version and Kernel Information
  hosts: ot_nodes:idmz_nodes
  # if gatheer_facts is set to true, ansible will automatically collect system information (facts) about the target hosts before executing any tasks. This includes details like the operating system, distribution, version, and other relevant information.
  # so that we can access ansible_facts.distribution, ansible_facts.distribution_version, and ansible_facts.distribution_release in the debug task.
  gather_facts: true
  become: false
  tasks:
    - name: Get kernel architecture details via uname
      # Use the command module to run 'uname -a' and capture the output
      ansible.builtin.command: uname -a
      # Register the output to a variable for later use
      register: uname_output
      # Indicate that this task does not change the system state
      changed_when: false

    - name: Display distribution, release version, and kernel info
      # Use the debug module to print the gathered information in a structured format
      # inventory_hostname we can use since we have gathered facts enabled, we can access ansible_facts for distribution and version details
      # inventory_hostname is jinja variable that represents the name of the current host being processed in the playbook. 
      # It is useful for displaying host-specific information in a multi-host playbook run.
      ansible.builtin.debug:
        msg: "{{ inventory_hostname }} is running {{ ansible_facts.distribution }} {{ ansible_facts.distribution_version }} (Codename: {{ ansible_facts.distribution_release }}) | Kernel: {{ uname_output.stdout }}"
```

Templating (Jinja2)

* https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_templating.html

## configure_apt_proxy.yml

## verify_firewall_isolation.yml

## update_apt.yml

## mount_datadrive_check.yml

## mount_datadrive_for_mysql_azure.yml

## mount_datadrive_for_mysql_generic_hyperv.yml

# Quickguide for IT OT LAB Advanced 102

## deploy_mysql_check.yml

## deploy_mysql.yml
