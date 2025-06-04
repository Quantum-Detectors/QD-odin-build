Change log
==========

Changes to this repository are recorded below.

The format is based on `Keep a Changelog
<https://keepachangelog.com/en/1.0.0/>`_, and this project adheres to `Semantic
Versioning <https://semver.org/spec/v2.0.0.html>`_.

0.3.3
-----

Changed:

 - The procserv-Top window now extends to show all Frame recievers


0.3.2
-----

Changed:

 - Config files are generated instead of copied.

Added:

 - Kill script added to scripts

0.3.1
-----

Changed: 

 - Version of ADOdin (10-4qd-1-1) without resgrades

0.3.0
-----

Added:

- Add support for opening X3X2 list mode files (for corresponding version of
  xspress-detector) to `xspress-view` GUI application
- Add build in place support for Odin build scripts for easier building during
  development

Changed:

- Reorganised configuration folder structure to make it cleaner
- X3X2 4 channel configuration of frame processors now set for correct channels
- Updated xspress-detector to 0.5.0+qd0.2

Fixed:

- corrected typos in `stFrameProcessor3.sh` and `stFrameProcessor4.sh` for
  `mk2-8chan` configuration
- Add `fr_adapter_name` to frame processor adapter config in `odin_server.cfg`
  to fix Xspress adapter failing to configure when running in list mode
- Add `hdf5plugin` dependency to make sure HDF5 plugin path is set properly
  when running Python GUI applications


0.2.0
-----

Added:

- ADOdin IOC substitution templates for 2, 4 and 8 channels
- Organised Odin runtime configuration into different numbers of channels and
  revisions
- More Python CLI entry points

  - Acquisition using ADOdin PVs
  - HDF5 data viewer GUI app for MCA data
  - List mode listener to get events from ADC TCP/IP socket and save them in
    binary format
  - List mode decoder to convert binary event data files into HDF5 or plot them

Changed:

- Updated Xspress binaries to 2024-12-19 version for open list mode TCP sockets
- Changed Python scripts into full Python module in python/ directory
- Improved Odin and EPICS build scripts to be able to build each component
  individually
- Improved server deploy scripts
- Pinned every software component to a release version or commit
- Now get log4cxx development package from standard package manager


0.1.0
-----

Added:

- Add Dockerfile for CentOS Stream 9 image with packages required
- Add build scripts to ./scripts directory for installing Odin software packages
- Add deploy scripts to ./server for configuring a new server
- Add xspress binaries and headers to xspress directory (built with
  CentOS Stream 9 using 2024-06-03 version of repository)
- Add Odin configuration files for running an 8 channel Xspress Mk1 system
- Basic Python script to plot captured datasets (once decompressed)
