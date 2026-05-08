# MapAction Ansible Experiment - ENDEXs

(Not prioritised)

- switch to public keys to access Windows (to avoiding needing to customise OpenSSH server config)
  - https://rys.pw/books/wiki/page/windows#bkmrk-post-install-script:~:text=for%20the%20upgrade.-,Setting%20up%20OpenSSH,-Due%20to%20this
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
- custom ArcPro package https://community.chocolatey.org/courses/creating-chocolatey-packages? (dependencies)
- custom MA toolbar package?
- refactor playbook (roles, loops, etc.)
  - https://github.com/AlexNabokikh/windows-playbook/blob/master/tasks/fonts.yml#L41C3-L42C29
- how do we test deployments (Azure VMs)?
- proper secrets for packages endpoint and login pass (until public key used)
- Windows updates?
- use proper endpoint and presigned URLs to download packages
- document limitations (no reinstall, resetting)
- document lifecycle (format -> bootstrap -> provision -> use -> reformat)
- Map Export plugin for QGIS and other requirements from https://mapaction.atlassian.net/wiki/spaces/techcircle/pages/11255643866/Mission+Software+Requirements#QGIS-Environment-Components
- use custom PS module for font install
- add a README to MA_PROVISIONING directory
- review https://github.com/AlexNabokikh/windows-playbook
- review https://rys.pw/books/wiki/page/windows#bkmrk-post-install-script
- humanitarian icons QGIS and ArcPro styles
- device security (defender, bit-locker?, having admin account separate from `Mapaction`?)
- in-place upgrades (from fixed profile to fixed profile - e.g. MA-2026-01-20 to MA-2026-04-02, etc.)
- get packages from Google Drive (auth?)?
- e2e test for the toolbar
- enable WSL by default?
  - seems to mess with SSH service (keeps becoming stopped) so maybe not
- bundle actual Ansible config used for local use via WSL? (probably won't work fully offline)
- cleanup bootstrap script if saved to the desktop
- developer profile (things like WSL, HyperV Docker, etc.)
- Office version is unsupported
- Office `en-gb` locale
- figure out MS Access Database Engine (and a test to ensure it's working)
- change `C:\MA_PROVISIONING\Font`\ to `C:\MA_PROVISIONING\fonts` (lowercase)
- move `C:\MA_PROVISIONING\ArcGISPro` to `C:\MA_PROVISIONING\software\ArcGISPro` (namespaced under software)
- Windows unattended setup? https://schneegans.de/windows/unattend-generator
- store laptop number as asset tag in UEFI?
- formalise Azure test VMs, Terraform?
- how do we handle Arc licensing? (named user or single use?)
- how were things like the D drive partition handled? (is this still needed?)
- how are things like printer drivers handled?

From https://mapaction.atlassian.net/wiki/spaces/techcircle/database/17848893459:

- remove `bginfo`
- do we need Adobe Reader over browser tools?
- do we need Google Chrome / Firefox over Edge PDFsam?
- check standalone `Python` requirement (what is this for?)
- propose to install `Signal` and `MS Teams` by default

From https://mapaction.atlassian.net/wiki/spaces/techcircle/pages/11255643866/Mission+Software+Requirements:

- says MS Access DB engine is needed, but not listed in https://mapaction.atlassian.net/wiki/spaces/techcircle/database/17848893459
- doesn't say GeoPandas is required for presumably https://mapaction.atlassian.net/wiki/spaces/GP/pages/16447995905/3W_4W+Jupyter+Notebook+JN

From https://mapaction.atlassian.net/wiki/spaces/GP/pages/16447995905/3W_4W+Jupyter+Notebook+JN and 1.3.1 notebook:

- says 'These packages i.e. geopandas, numpy etc are already installed in arcpro. There is no need to do anything else apart from running the cell', that isn't true for GeoPandas as per https://pro.arcgis.com/en/pro-app/3.4/arcpy/get-started/available-python-libraries.htm
