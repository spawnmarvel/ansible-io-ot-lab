# Ansible stack in Azure Proof of Concept (PoC) 


## Table of content

- [Ansible stack in Azure Proof of Concept (PoC)](#ansible-stack-in-azure-proof-of-concept-poc)
  - [Table of content](#table-of-content)
  - [DO417LS: Microsoft Windows Automation with Red Hat Ansible](#do417ls-microsoft-windows-automation-with-red-hat-ansible)
  - [15 Ansible Playbooks Example for Windows Administration](#15-ansible-playbooks-example-for-windows-administration)
  - [Ansible handles Windows updates natively example](#ansible-handles-windows-updates-natively-example)
- [Using Ansible and Windows](#using-ansible-and-windows)
  - [Managing Windows hosts with Ansible](#managing-windows-hosts-with-ansible)
    - [What is WinRM?](#what-is-winrm)
    - [WinRM Setup 5985](#winrm-setup-5985)



## DO417LS: Microsoft Windows Automation with Red Hat Ansible

Learn how to automate administration on Windows Server to enable your DevOps workflow. Microsoft Windows Automation with Red Hat Ansible is designed for Windows Server professionals without previous Ansible experience. 

https://www.glasspaper.no/en/courses/do417-microsoft-windows-automation-with-red-hat-ansible/

## 15 Ansible Playbooks Example for Windows Administration

https://gist.github.com/devops-school/52c8de8924555f91c50e3a016556060f

## Ansible handles Windows updates natively example


Yes, absolutely. Ansible handles Windows updates natively and can target specific Microsoft KB numbers across your Windows VMs (such as your OT target nodes) using the ansible.windows.win_updates module.

The module provides built-in parameters like include_kb to enforce precise patch selection, along with automatic reboot handling if an update requires it.


```yml
---
# Version: 1.0.0
# Description: Installs specific Microsoft KB updates on Windows target nodes and handles reboots automatically.

- name: Apply Targeted Windows Updates
  hosts: ot_windows_nodes
  gather_facts: false
  tasks:
    - name: Install specific Microsoft KB updates
      ansible.windows.win_updates:
        category_names:
          - SecurityUpdates
          - CriticalUpdates
          - UpdateRollups
        include_kb:
          - KB5034441
          - KB5034127
        state: installed
        reboot: true
        reboot_timeout: 1200
      register: kb_install_result

    - name: Display update execution summary
      ansible.ansible.builtin.debug:
        msg: >
          Host {{ inventory_hostname }} update status:
          Reboot required: {{ kb_install_result.reboot_required }}
          Updated count: {{ kb_install_result.installed_update_count }}
```

# Using Ansible and Windows

When using Ansible to manage Windows, many of the syntax and rules that apply for Unix/Linux hosts also apply to Windows, but there are still some differences when it comes to components like path separators and OS-specific tasks. This document covers details specific to using Ansible for Windows

* https://docs.ansible.com/projects/ansible/latest/os_guide/windows_usage.html


## Managing Windows hosts with Ansible

Managing Windows hosts is different from managing POSIX hosts. If you have managed nodes running Windows, review these topics.


### What is WinRM?

WinRM is a management protocol used by Windows to remotely communicate with another server. It is a SOAP-based protocol that communicates over HTTP/HTTPS and is included in all recent Windows operating systems. Since Windows Server 2012, WinRM has been enabled by default, but in some cases, extra configuration is required to use WinRM with Ansible.

Ansible can use WinRM through the psrp or winrm connection plugins. These plugins have their own Python requirements that are not included in the Ansible package and must be installed separately.

### WinRM Setup 5985


Before Ansible can connect using WinRM, the Windows host must have a WinRM listener configured. This listener will listen on the configured port and accept incoming WinRM requests.

While this guide covers more details on how to enumerate, add, and remove listeners, you can run the following PowerShell snippet to setup the HTTP listener with the defaults:

```ps1
# Enables the WinRM service and sets up the HTTP listener
Enable-PSRemoting -Force

# Opens port 5985 for all profiles
$firewallParams = @{
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTP-In)'
    LocalPort   = 5985
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams

# Allows local user accounts to be used with WinRM
# This can be ignored if using domain accounts
$tokenFilterParams = @{
    Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Name         = 'LocalAccountTokenFilterPolicy'
    Value        = 1
    PropertyType = 'DWORD'
    Force        = $true
}
New-ItemProperty @tokenFilterParams
```

You can add a HTTPS listener with a self signed certificate, read more at the link


* https://docs.ansible.com/projects/ansible/latest/os_guide/intro_windows.html