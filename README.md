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

- ~~can install Windows via standard installer and minimally configure~~
- ~~can register a static DHCP reservation for laptop within the office server~~
- ~~can ping a laptop based on this static address~~
- [x] can ping a laptop via Ansible ~~based on this static address~~
- [x] can run a simple task within an Ansible playbook (creating a text file on the desktop)
- [x] can install simple software such as ~~VLC~~ VS Code
- [x] can install more complex software such as ArcGIS Pro with the MA toolbar

> [!NOTE]
>
> In this demonstration/experiment, a single laptop is targeted without a network using DHCP registration.
> Consequently, the DHCP and static address elements of the provisioning project milestones are ignored/untested.
>
> Additionally, in-place Windows resets were used instead of full re-installations. This milestone is therefore also 
> ignored/untested. 

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
  - [x] Google Chrome (checksum skipped due to error)
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
  - [x] MS Office
  - Python *skipped to clarify need*
  - [x] MS Teams
  - [x] Signal
- fonts as per https://mapaction.atlassian.net/wiki/spaces/techcircle/pages/11255643866/Mission+Software+Requirements:
  - [x] OCHA Humanitarian Icons
  - [x] Roboto

## Usage

### Overview

1. install Windows with a conventional MapAction admin user account (first run only)
2. enable SSH access for Ansible to connect to machine (first run only)
3. run Ansible playbook to install and configure software

### Setup Windows

> [!CAUTION]
> This will remove all data on the laptop.

> [!NOTE]
>
> These steps were developed using an existing MA configured laptop 
> [Reset](https://support.microsoft.com/en-us/windows/reset-your-pc-0ef73740-b927-549b-b7c9-e6f2b48d275e) to its 
> original state. 
>
> Whilst this is not the same as a full reinstallation, it's good enough for this demonstration (and probably generally?).

Reset an existing Windows 11 installation:

- from *Settings* -> *System* -> *Recovery* -> *Reset PC*
- choose *Remove Everything*, then *Cloud Download*, then *Next*, then *Reset*
- the laptop will download installation files and automatically restart, then reset, restart and install updates
- once reset and updated (after several more possible restarts), the laptop will enter Windows setup
- choose *United Kingdom* as the country/region and keyboard layout (skip additional)
- connect to a relevant network (not public)
- accept the licence agreement
- name the device based on its asset label (e.g. `MA-LAPTOP60`)
- the laptop will restart and re-enter setup
- choose *Setup for work or school*
- choose *Sign-in options* when asked to sign in, then *Domain join instead*
- use `Mapaction` as the name of the local account
- give any answer for the required security questions
- skip biometrics setup
- *opt-in* to location services
- *opt-out* of find my device
- send *required only* diagnostic data sharing
- *opt-out* of improving inking and typing
- choose *No* to personalised offers
- Windows will create a profile and sign in

### Bootstrap Windows

Configure a machine with Windows installed for access by Ansible:

1. copy the `bootstrap.ps1` PowerShell script to the desktop
2. run the script from a privileged PowerShell session [1]
3. ensure the network profile is set to *private* not *public* (providing you are on a trusted network)

> [!NOTE]
> Checking the SSH server config file exists is temperamental. You may need to run the bootstrap script again if it fails.

[1]

```shell
> powershell.exe -ExecutionPolicy Bypass -File C:\Users\Mapaction\Desktop\bootstrap.ps1
```

### Run Ansible provisioning

```shell
% source .venv/bin/activate
% ansible-playbook playbook.yml
```

> [!NOTE]
> Running the playbook takes around 40 minutes on an unprovisioned machine.

## Implementation

An Ansible playbook `playbook.yml` is used to to configure a laptop for use.

A local provisioning folder `C:\MA_PROVISIONING` is created for storing copies of hosted packages.

PowerShell helper scripts in `files\` are used for some tasks (such as font installation)

### Software tasks

Chocolately is used to install applications except ArcGIS Pro and Microsoft Office.

> [!NOTE]
> For troubleshooting, the Chocolately install cache is available at `%TEMP%\chocolatey`.

#### ArcGIS Pro

The ArcGIS installer is downloaded from the packages web server and extracted to the local provisioning folder.

The MSI package is run in silent mode, with arguments to:

- install system wide
- include the semantic search and tool suggestion local AI features
- allow unsigned add-ins (for the MapAction toolbar) SemanticSearch,ToolSuggestions
- prevent in-app updates (to ensure compatibility with the MapAction toolbar)

> [!TIP]
> The ArcGIS installer is kept for manual reinstallation if needed given it's size.

Post installation:

- required patches are installed (as MSI packages)
- an ArcGIS Pro add-ins folder is created within the local provisioning folder
- this folder is configured as an add-ins search path via the registry
- the default Conda environment is cloned, and made active within Pro, to allow installing additional packages

#### ArcGIS Pro MapAction toolbar

The MapAction toolbar ArcGISPro add-in file is download from the packages web server to the pre-created add-ins
folder. The add-in should be picked up and used within Pro automatically.

#### ArcGIS Pro Conda

The [GeoPandas](https://geopandas.org/en/stable/) Python package is installed into a non-default ArcGIS Pro Conda 
environment for running the 
[W3 notebook](https://mapaction.atlassian.net/wiki/spaces/GP/pages/16447995905/3W_4W+Jupyter+Notebook+JN).

#### Microsoft Office

A default Office 2019 installation is performed, with limitations:

- an `en-gb` (UK English) language pack no longer seems to be available
- a configuration file generated with [Microsoft's tool](https://config.office.com/deploymentsettings) is not used if
  specified

As workarounds:

- `en-us` is used as an explicit language pack
- the Office product key is updated after installation using some additional commands

> [!NOTE]
> The lack of a UK language pack, and installing other languages (French and Spanish) is not ideal, but as Office 2019 
> is no longer supported, no further work to resolve this is planned.

### Font tasks

Fonts are downloaded from the packages web server and stored in the local provisioning folder.

Fonts are installed system wide via a helper script.

## Setup

### Package hosting

Setup needed for hosting software and other packages:

1. create a [Cloudflare R2](https://developers.cloudflare.com/r2/get-started/) bucket
2. upload required software and packages [1]
3. enable the public development URL
4. use this URL as the `software_packages_endpoint` variable in Ansible

> [!TIP]
> To upload large files via the command line, use the S3 CLI with Cloudflare as a custom endpoint:
>
> ```shell
> % AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=xxx aws s3 cp ~/Downloads/foo.exe s3://$bucket/.../ --endpoint-url https://$account.r2.cloudflarestorage.com --region auto
> ```
>
> Where: `$account` is the Cloudflare account ID, `$bucket` is the R2 bucket name and `xxx` are bucket credentials.

E.g.

```shell
% AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=xxx aws s3 cp  ~/Downloads/ArcGISPro_34_192912.exe s3://mapaction-laptop-assets/software/arcgis-pro/3.4.2/ --endpoint-url https://a8f7784516857bf5334a1fd14e92c7e2.r2.cloudflarestorage.com --region auto
```

[1]

- ArcGIS Pro 3.4.0 installer
  - from MyEsri
- ArcGIS Pro 3.4.1 patch
  - from MyEsri
- ArcGIS Pro 3.4.2 patch
  - from MyEsri
- MapAction toolbar for ArcGIS Pro 3.4.2.5
  - from https://drive.google.com/drive/folders/1N3kUqPWmpcjSJSc8mJECQwCTtMVEF_ZA
- Roboto font
  - from https://fonts.google.com/specimen/Roboto
- Humanitarian Icons font
  - from https://github.com/mapaction/ocha-humanitarian-icons-for-gis 

### Ansible control node setup

Setup needed to run Ansible:

1. setup project [1]
2. amend `inventory.yml` to reflect target laptops (i.e. update `MA-LAPTOP60` to reflect the laptop(s) you have available)
3. set `ansible_password` in `inventory.yml` to the conventional MapAction password
4. set `software_packages_endpoint` in `playbook.yml` to a web server hosting required software and other packages
5. set `office_key` in `playbook.yml` to a valid Office 2019 professional plus volume licence product key

[1]

For macOS:

```shell
% brew install uv git
% git clone https://github.com/felnne/ma-ansible-laptops.git
% cd ma-ansible-laptops/
% uv sync
```

For Windows Subsystem for Linux:

> [!NOTE]
> Ansible cannot be run from a Windows machine directly.

```shell
> wsl --install
# reboot
> wsl --install ubuntu
# set account information
$ cd ~
$ curl -LsSf https://astral.sh/uv/install.sh | sh
$ git clone https://github.com/felnne/ma-ansible-laptops.git
$ cd ma-ansible-laptops/
$ uv sync
```

### Azure VMs

> [!WARNING]
> This section is Work in Progress (WIP) and may not be complete/accurate.

Setup needed to create disposable VMs as Ansible targets:

1. sign up for Azure and enable PAYG billing
2. *Home* -> *Create a Resource* -> *Virtual Machines*:
  - Environment: *Dev/Test*
  - Type: *D*
  - Resource group: `ma-laptop-provisioning`
  - Name: `MA-LAPTOP-Vxx`
  - Region: *UK (South)*
  - Zone: *Azure selected*
  - Image: *Windows 11 Pro*
  - Spot discount: *True*
  - Eviction policy: *Delete*
  - Size: *D2*
  - Username: `Mapaction`
  - Password: (Random)
  - Inbound ports: *3389*, *22* (RDP, SSH)
  - Disks: (accept defaults)
  - Network: (accept defaults, except enable 'Delete public IP and NIC when VM is deleted')
  - Management: (skip)
  - Monitoring: (accept defaults, except disable Boot diagnostics)
  - Advanced (skip)
  - Tags: (skip)
3. when provisioned, go to *VM* -> *Primary NIC public IP* -> *associated public IPs* -> *x.x.x.x* -> *Settings* -> *Configuration*:
  - DNS name label: `$hostname` (e.g. `ma-laptop-v02.uksouth.cloudapp.azure.com`)
5. RDP into VM and follow [Bootstrap Windows](#bootstrap-windows), inc. setting network as private

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
% ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -vvvv Mapaction@x.x.x.x
```

Verifies network connectivity, SSH service and authentication.

If you see `Operation timed out`, check `sshd` Windows service is running.

> [!NOTE]
> Replace `x.x.x.x` with an IP or DHCP hostname.

> [!TIP]
> `-o PreferredAuthentications=password` and `-o PubkeyAuthentication=no` options are set to guard against any public
> keys tried automatically triggering too many authentication errors, preventing the connection.
>
> Depending on the SSH config of your control machine, this may not be necessary (but won't hurt).

### Troubleshoot Windows ping

```shell
# enable ping responses
> Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
# disable ping responses
> Disable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
```

> [!TIP]
> It's best practice to not leave ping relies enabled.

### Troubleshoot Windows firewall

```shell
# disable firewall
> Set-NetFirewallProfile -All -Enabled False
# enable firewall
> Set-NetFirewallProfile -All -Enabled True
```

> [!WARNING]
> Only disable the firewall when needed for testing.

> [!NOTE]
> Additionally, check the network profile is set to *private* not *public* (assuming the current network is trusted).
