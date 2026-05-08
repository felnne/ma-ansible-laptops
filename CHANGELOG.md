# MapAction Ansible Experiment - Change log

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-05-08

### Added 

- Tasks for installing Microsoft Office

## [0.4.0] - 2026-04-25

### Added

- Helper script for installing fonts
- Tasks for installing Roboto and Humanitarian fonts
- Task for installing Google Chrome

### Changed

- Improved Windows bootstrap PowerShell script (OpenSSH components and firewall rule)

### Removed

- Unused template from initial tasks

## [0.3.0] - 2026-04-24

### Added

- Tasks for installing ArcGIS Pro, Toolbar for Pro and custom Conda environment with GeoPandas
- Task for installing MS Teams

### Changed

- Improved Windows bootstrap PowerShell script (simplifying ad-hoc execution policy bypass)

## [0.2.0] - 2026-04-19

### Added

- Tasks for installing simple software

### Changed

- Improved Windows bootstrap PowerShell script (no longer requires PowerShell 7, patching OpenSSH server config)

### Removed

- Initial test tasks

## [0.1.0] - 2026-04-19

### Added

- Initial Windows bootstrap PowerShell script
- Playbook with tasks to create a file on the desktop
- Ansible control node environment
- Initial experiment
