Change log
==========

Changes to this repository are recorded below.

The format is based on `Keep a Changelog
<https://keepachangelog.com/en/1.0.0/>`_, and this project adheres to `Semantic
Versioning <https://semver.org/spec/v2.0.0.html>`_.

0.5.0
-----

Changed:

- Moved pyxspress to separate repository and just use a built Wheel for
  deployment
- `copy_build_config.sh` now uses the current user to set permissions, which
  is useful when testing on a developer system.
- Split `/config` directory into `/edm_config` and `/epics_config` to avoid
  name conflict when generating runtime Xspress Odin configuration in test
  mode (which uses the CWD)

Fixed:

- Remove existing pyxspress wheels when copying server configuration
- Remove existing Xspress binaries when copying server configuration


0.4.0
-----

Added:

- Added additional command line argument for setting EPICS directory

Changed:

- Updated README based on current instructions
- Only build pyxspress Wheel when copying build config
- pyxspress Wheel now gets deployed to `/odin/util_wheels`
- Moved configuration Python environment from `/odin/config/conf_venv` to
  `/odin/util_python` to keep `/odin/config` cleaner
- Moved Odin and EPICS build scripts to `/odin/scripts`
- Renamed `config-generate` to `xspress-create-config` and moved to CLI module
  using Click instead of argparse
- Moved default target paths to the ConfigGenerator as class attributes

Fixed:

- Restored configuration files required for building EPICS modules and for
  EDM runtime
- Fix setuptools build warnings by adding init files to modules and templates
  folders.
- Fixed expanded substutions file not being copied to ADOdin IOC Db directory
- Fixed double brace in Odin channel template string left over from f-string
  formatting


0.3.4
-----

Changed:

- Configuration enviroment is moved further away from the python module for odin
  components so that they don't interfer with each otherwise
- Changed the order of ODIN processes so that static ones are first and dynamic ones,
  i.e frame processor and receiver which changes per card. 


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
