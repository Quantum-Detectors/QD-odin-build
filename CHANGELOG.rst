Change log
==========

Changes to this repository are recorded below.

The format is based on `Keep a Changelog
<https://keepachangelog.com/en/1.0.0/>`_, and this project adheres to `Semantic
Versioning <https://semver.org/spec/v2.0.0.html>`_.

0.8.8
-----

Updated:

- updated pyxspress to 0.7.8, fixes live view endpoint


0.8.7
-----

Changed:

- Updated to pyxspress to 0.7.7
- Updated xspress-detector to 0-10-4qd1-5
- Fixes competition of the 15510 port with larger systems.


0.8.6
-----

Added:

- Updated to xspress-detector 0.5.0+qd0.11 
- Updated xspress-detector to 0-10-4qd1-4
- These changes introduce the reset timestamps option into the system. It adds a PV for control so the user can select
  whether to reset timestamps at the start of each acquisition or not. By default, this is disabled.

Changed:

- EDM screen changed for the Xspress Odin control to change the size of the boxes to make them more readable.


0.8.5
-----

Changed:

- Updated to pyxspress wheel to 0.7.6 to add xspress-switch-mode functionality.
  To switch between ODIN, Autocalb and EPICS seamlessly.

0.8.4
-----

Changed:

- Updated to xspress-detector 0.5.0+qd0.10 to fix frame processor crashing issue
  when running an MCA acquisition due to allocating no memory for the initial
  MCA data when file saving was not enabled.
- Updated to pyxspress 0.7.5 to set master dataset of first frame processor
  to second channel, even if marker channels are enabled. The number of memory
  blocks written is then more comparable to other frame processors, assuming
  similar event rates.


0.8.3
-----

Changed:

- Updated to xspress-detector 0.5.0+qd0.9 to enable resetting the timestamps at
  the beginning of every acquisition to keep the marker channels and real
  channels synchronised
- Updated pyxspress to 0.7.4 to add list mode master datasets to frame processors
  to indicate some form of file writing progress based on number of memory
  blocks written (which is separate from the number of time frames written)


0.8.2
-----

Changed:

- Updated ADOdin to 0-10-4qd1-3 to fix incorrect numbering of software start/stop
  and IDC trigger modes and also update the default Odin data path to /tmp so it
  starts as a valid path
- Updated pyxspress to 0.7.3 to generate ADOdin IOC with /tmp filepath as default
- Updated xspress-detector to 0.5.0+qd0.8 to add detector acquire status and
  frame counter when in X3X2 list mode
- Now unsets EPICS_CAS_INTF_ADDR_LIST, normally set by xspress3 in the normal
  bashrc file, in Odin bashrc file to see Odin IOC PVs


0.8.1
-----

Added:

- TCP relay application TcpRelay to fan out Xspress list mode data to multiple
  clients.

Changed:

- Updated to pyxspress 0.7.2 for TCP relay configuration support
- Updated to xspress-detector to 0.5.0+qd0.7 for TCP relay server support


0.8.0
-----

Changed:

- Updated xspress-detector to 0.5.0+qd0.6

  - Added muxing of TTL inputs so that the marekr channel data is input from TTL 0 and TTL 1
  - Data can now be written from marker channels into hdf5 file in file '_A'

- Updated to pyxspress 0.7.1

  - Fixed issue with xspress-view crashing when opening list mode files with
    marker channels
  - Config generator now has a flag '-mc' to enable marker channels in the
    generated configuration


0.7.0
-----

Changed:

- Updated to pyxspress 0.7.0

  - Add `xspress-list-mode-check` script to check ordering of events in a saved
    acquisition
  - Set `XSP3READOUT` to `frames` in the control server script to set default
    readout mode to be optimised for MCA data
  - `xspress-list-mode-decode` now writes HDF5 files in the same format as Odin
    using separate datasets for each event field
  - Changed default run flags in IOC boot script template to Scalers and Hist
    without playback data
  - Fixed issue with example Python list mode decoder not correctly checking the
    source channel of a TCP packet matches the channels it is looking for

- Updated to xspress-detector 0.5.0+qd0.5

  - Increases size of list mode frame decoder buffers from 5 to 12,800 (100MB)
  - Added logging checks for timestamps and time frames going back in time -
    which is a side-effect of running out of receiver buffers
  - The Xspress channel control register data source is now set to match the
    run flag setting (ADC or playback data) when configuring the system
  - The logic to flush and close the acquisition is tidied up in the list mode
    processor to only be called once - whether the acquisition is stopped
    manually or has reached the desired number of frames


0.6.0
-----

Added:

- Added missing XCB dependencies needed for Qt6 (used by pyxspress for the GUI)

Changed:

- Updated xspress-detector to 0.5.0+qd0.4

  - fix the number of processes configured when using list mode
  - separate datasets use for each event field

- Updated to pyxpress 0.6.0 to add support for separate list mode datasets

  - Updates the configuration generated for the frame processors
  - Updates support for viewing the new list mode datasets in the xspress-view
    GUI


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
