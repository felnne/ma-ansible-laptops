# MapAction Ansible Experiment - ENDEXs

(Not prioritised)

- switch to public keys to access Windows (to avoiding needing to customise OpenSSH server config)
- ~~use installer for bootstrapping?~~ (not worth it)
- embed bootstrapping within Windows installer?
- some sort of report that logs what provisioning did?
- chocolatey `x` vs `x.install` packages?
- how do we verify installs?
- VSCode plugins?
- linting playbooks / Ansible?
- webhook to log details centrally
- pre-warm applications?
- set https://docs.ansible.com/projects/ansible/latest/collections/ansible/windows/win_computer_description_module.html
- set https://docs.ansible.com/projects/ansible/latest/collections/ansible/windows/win_hostname_module.html
- use https://github.com/Esri/arcgis-powershell-dsc/blob/main/SampleConfigs/v5/v5.0.1/DesktopPro/Pro-Named.json?
- custom ArcPro package https://community.chocolatey.org/courses/creating-chocolatey-packages?
- refactor playbook (roles, loops, etc.)
- how do we test deployments (Azure VMs)?
- proper secrets for packages endpoint and login pass (until public key used)

From https://mapaction.atlassian.net/wiki/spaces/techcircle/database/17848893459:

- remove `bginfo`
- do we need Adobe Reader over browser tools?
- do we need Google Chrome / Firefox over Edge PDFsam?
- check standalone `Python` requirement (what is this for?)
- propose to install `Signal` and `MS Teams` by default
