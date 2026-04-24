# MapAction Ansible Experiment

Demonstration of using Ansible for provisioning MapAction laptops.

## Aim

A standalone demonstration of using Ansible to provision a Windows laptop for use in MapAction.

Created by @felnne to check Ansible is a viable option for provisioning and what is needed in terms of pre-provisioning
configuration.

Intended to implement parts of the minimal workflow needed to provision a MapAction laptop as set out in
[Confluence](https://mapaction.atlassian.net/wiki/spaces/missions/pages/18013814785/2026-Global-Server-Status-and-Laptop-Provisioning-Current-Status-Milestones#Milestones)

> [!IMPORTANT]
> This repo is not the real implementation of that project. That will come later and be hosted somewhere else.
>
> This effort is intended only to implement parts of the proposed workflow to rule out major sources of risk.

I.e. the playbooks into this specific project will not cover all software needed on laptops, only enough to prove 
Ansible generally works.

## Progress

Against provisioning project 
[Milestones](https://mapaction.atlassian.net/wiki/spaces/missions/pages/18013814785/2026-Global-Server-Status-and-Laptop-Provisioning-Current-Status-Milestones#Milestones):

- [ ] can install Windows via standard installer and minimally configure
- ~~can register a static DHCP reservation for laptop within the office server~~
- ~~can ping a laptop based on this static address~~
- [x] can ping a laptop via Ansible ~~based on this static address~~
- [x] can run a simple task within an Ansible playbook (creating a text file on the desktop)
- [x] can install simple software such as ~~VLC~~ VS Code
- [x] can install more complex software such as ArcGIS Pro with the MA toolbar

> [!NOTE]
>
> In this demonstration/experiment, a single laptop is targeted without a network using DHCP registration.
>
> Consequently, the DHCP and static address elements of the provisioning project milestones are ignored.

Additional progress:

- [x] `ping` can generically connect to a remote Windows machine
  - requires enabling Windows firewall rule
- [x] ruled out needing PowerShell v7, default v5 is fine
- [x] automated patching OpenSSH config to enable admin users to use password auth
- software as per https://mapaction.atlassian.net/wiki/spaces/techcircle/database/17848893459:
  - Windows (implicit)
  - [x] .Net desktop runtime [8.x]
    - [x] ArcPro [3.4.0]
      - [x] ArcPro [3.4.1]
      - [x] ArcPro [3.4.2]
      - [x] MapAction Toolbar
      - [x] GeoPandas python dependency for 3W process
  - [x] QGIS [3.44]
  - [x] Adobe Reader
  - [ ] Google Chrome *skipped, checksum error on install*
  - [x] Firefox
  - [x] PDFsam
  - [x] NextCloud Client
  - [x] VLC
  - [x] 7Zip
  - [x] Slack
  - [x] Google Earth Pro
  - [x] NotePad++
  - [x] VS Code
  - [x] Google Drive
  - [x] WinDirStat
  - [x] InkScape
  - [x] GIMP
  - [x] Power BI Desktop
  - [ ] MS Office *Skipped as not sure which version*
  - [ ] Python *skipped to clarify need*
  - [x] MS Teams
  - [x] Signal
- fonts as per ...
  - [ ] OCHA Humanitarian Icons
  - [ ] Roboto
  - [ ] FontAwesome
- other as per ...
  - [ ] printer drivers

Questions:

- how do we handle Office?
- how do we handle Arc licensing? (named user or single use?)
- how were things like the D drive partition handled? (is this still needed?)

## Usage

### Overview

1. install Windows with a conventional MapAction admin user account (first run only)
2. enable SSH access for Ansible to connect to machine (first run only)
3. run Ansible playbook to install and configure software

### Setup Windows

> [!NOTE]
>
> These steps were developed using an existing MA configured laptop 
> [Reset](https://support.microsoft.com/en-us/windows/reset-your-pc-0ef73740-b927-549b-b7c9-e6f2b48d275e) to its 
> original state. 
>
> Whilst this is not the same as a full reinstallation, it's good enough for this demonstration.

Configure a machine to run Windows:

1. install Windows 11
2. when asked, name the machine based on its assigned label (e.g. `MA-LAPTOP60`)
3. when asked, create a `Mapaction` local account (choose work computer and domain joined)

### Bootstrap Windows

Configure a machine with Windows installed for access by Ansible:

1. copy the `bootstrap.ps1` PowerShell script to the desktop
2. run the script from a privileged PowerShell session [1]

[1]

```shell
> Set-ExecutionPolicy Bypass -File C:\Users\Mapaction\Desktop\bootstrap.ps1
```

### Run Ansible provisioning

```shell
% source .venv/bin/activate
% ansible-playbook playbook.yml
```

> [!NOTE]
> Running the playbook is not quick where Arc needs to be installed!

## Implementation

...

ArcGIS installer kept in case reinstallation needed

...

Uploading large files to R2:

```shell
% AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=xxx aws s3 cp ~/Downloads/xxx.exe s3://mapaction-laptop-assets/software/foo/1.2.3/ --endpoint-url https://a8f7784516857bf5334a1fd14e92c7e2.r2.cloudflarestorage.com --region auto
```

## Setup

I.e. Setup needed to run this project, on a machine Ansible will be run from.

1. setup project [1]
2. amend `inventory.yml` to reflect target laptops (i.e. update `MA-LAPTOP60` to reflect the laptop(s) you have available)
3. set `ansible_password` in `inventory.yml` to the conventional MapAction password
4. set `software_packages_endpoint` in `playbook.yml` to a web server hosting required software and other packages

[1]

```shell
% brew install uv git
% git clone https://github.com/felnne/ma-ansible-laptops.git
% cd ma-ansible-laptops/
% uv sync
```

## Troubleshooting

### Troubleshoot Ansible

```text
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
> Replace `192.168.122.141` with an IP or DHCP hostname.

> [!TIP]
> `-o PreferredAuthentications=password` and `-o PubkeyAuthentication=no` options are set to guard against any public
> keys tried automatically triggering too many authentication errors, preventing the connection.
>
> Depending on the SSH config of your control machine, this may not be necessary (but won't hurt).

### Troubleshoot Windows Firewall

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
