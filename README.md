# MapAction Ansible Experiment

Demonstration of using Ansible for provisioning MapAction laptops.

## Aim

A standalone, demonstration of the using Ansible to provision a single Windows laptop.

Created for @felnne to verify Ansible approach will work and what is needed in terms of pre-provisioning configuration.

Intended to implement parts of the minimal workflow needed to provision a MapAction laptop as set out in
[Confluence](https://mapaction.atlassian.net/wiki/spaces/missions/pages/18013814785/2026-Global-Server-Status-and-Laptop-Provisioning-Current-Status-Milestones#Milestones)

> [!IMPORTANT]
> This repo is not the real implementation of that project. That will come later and be hosted somewhere else.
>
> This effort is intended only to implement parts of the proposed workflow to rule out major sources of risk.

I.e. the playbooks into this specific project will not cover all software needed on laptops, only enough to prove 
Ansible generally works.

## Progress

Agaist provisioning project 
[Milestones](https://mapaction.atlassian.net/wiki/spaces/missions/pages/18013814785/2026-Global-Server-Status-and-Laptop-Provisioning-Current-Status-Milestones#Milestones):

- [ ] can install Windows via standard installer and minimally configure
- ~~can register a static DHCP reservation for laptop within the office server~~
- ~~can ping a laptop based on this static address~~
- [x] can ping a laptop via Ansible ~~based on this static address~~
- [x] can run a simple task within an Ansible playbook (creating a text file on the desktop)
- [ ] can install simple software such as VLC
- [ ] can install more complex software such as ArcGIS Pro with the MA toolbar

> [!NOTE]
>
> In this demonstration/experiment, a single laptop is targetted without a network using DHCP registration.
>
> Consequently, the DHCP and static address elements of the provisioning project milestones are ignored.

Additional progress:

- [x] `ping` can generically connect to a remote Windows machine
  - requires enabling Windows firewall rule

## Usage

### Bootstrap Windows

Configure a Windows machine for configuration by Ansible:

1. install latest PowerShell version (minimum 7.0) - https://github.com/PowerShell/PowerShell/releases
2. copy and run `boostrap-windows.ps1` PowerShell script [1] from a privilged (in-built) PowerShell session
3. configure SSH Server config [2]

[1]

```shell
> powershell -NoProfile -ExecutionPolicy Bypass -File .\Desktop\ansible-ssh.ps1
```

[2]

In `C:\ProgramData\ssh\sshd_config`, change:

```
#PermitRootLogin prohibit-password

...

Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

To:

```
PermitRootLogin yes

...

Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
       PasswordAuthentication yes
```

### Run Ansible provisioning

```shell
% source .venv/bin/activate
% ansible-playbook playbook.yml
```

## Setup

I.e. Setup needed to run this project, on a machine Ansible will be run from.

1. setup project [1]
2. amend `inventory.yml` to reflect target laptops (i.e. update `MA-LAPTOP60` to reflect the laptop(s) you have available)
3. set `ansible_password` in `inventory.yml` to the conventional MapAction password

[1]

```shell
% brew install uv git
% cd ma-ansible-laptops/
% uv sync
```

## Troubleshooting

### Troubleshoot Ansible

```
% ansible laptops -m win_ping
192.168.122.141 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Checks Ansible can connect to all machines in the *laptops* inventory group via SSH.

> [!TIP]
> Make sure the `win_ping` module is used over the default `ping` which won't work for Windows based hosts.

### Troubleshoot SSH

```shell
% ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -vvvv Mapaction@192.168.122.141
```

Verifies network connectivity, SSH service and authentication.

> [!NOTE]
> Replace `192.168.122.141` with IP or DHCP hostname.

> [!TIP]
> `-o PreferredAuthentications=password` and `-o PubkeyAuthentication=no` options are set to guard against any public
> keys tried automatically triggering too many authentication errors, preventing the connection.
>
> Depending on the SSH config of your control machine, this may not be necessary (but won't hurt).

If needed, you can check the default shell version with:

```shell
% ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no Mapaction@192.168.122.141 '$PSVersionTable.PSVersion'
```

The minimum correct version is _7.x_. A version of _5.x_ (the default installed with Windows) is not supported.

### Troubleshoot windows firewall

```shell
# disable firewall
Set-NetFirewallProfile -All -Enabled False
# enable firewall
Set-NetFirewallProfile -All -Enabled True
```

> [!WARNING]
> Only disable the firewall when needed for testing.

> [!NOTE]
> Additionally, check the network profile is set to *private* not *public* (assuming the current network is trusted).
