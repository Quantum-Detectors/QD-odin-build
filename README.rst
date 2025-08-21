QD Odin build
-------------

This repository contains build files used to build the Odin software components
for Xspress readout systems.


Repository layout
=================

This repository contains the following components:

- config: configuration files

  - edm: runtime configuration for EDM
  - epics: synapps module versions and configure/RELEASE files for building

- python: Python module for generating configuration files and testing and
  using ADOdin
- scripts: Build scripts for Odin and EPICS
- server: Utility scripts for deploying onto a server
- xspress: Xspress binaries


Server scripts
==============

These are located in the `server/` directory. These are run to set up the
root installation path and provide the build scripts and runtime configuration
for the target system.

The install path is hard-coded to `/odin` and is set to be owned by `xspress3`.

The following scripts are available:

- `server/copy_build_config.sh` - sets up the install path, copies the build
  scripts and Xspress binaries, and some static configuration files used for
  EPICS and EDM.
- `server/dependencies.sh` - installs the dependencies required to build and
  run the Odin and related software

Note: the `dependencies` script should be run before trying to build the
software

After these scripts have run (assuming a fresh state) the Odin directory should
look something like the following:

.. code:: bash

    /odin/
    ├── epics
    │   ├── config
    │   │   ├── RELEASE.local
    │   │   ├── synapp_modules
    │   │   └── xspress_IOC_RELEASE
    │   └── edm
    │       ├── colors.list
    │       └── fonts.list
    ├── scripts
    │   ├── epics_build.sh
    │   ├── kill_odin.sh
    │   └── odin_build.sh
    ├── util_wheels
    │   └── pyxspress-0.5.0-py3-none-any.whl
    └── xspress
        ├── bin
        │   ├── imgd
        │   └── xspress3.server
        ├── include
        │   ├── datamod.h
        │   ├── femConfig.h
        │   ├── lmk_clocks.h
        │   ├── mainpage.h
        │   ├── os9types.h
        │   ├── xspress3_data_mod.h
        │   ├── xspress3_dma_protocol.h
        │   ├── xspress3_fem_api.h
        │   ├── xspress3.h
        │   └── xspress3_v7_clocks.h
        └── lib
            ├── libimg_mod.so.1.0.0
            └── libxspress3.so.1.0.0


Build scripts
=============

These are in the `scripts/` directory and are used to build all of the software
components required for Odin and related software. They are copied to the target
server at `/odin/scripts` when the `copy_build_config.sh` script is run.

- `scripts/epics_build.sh` - builds EPICS base and related modules and
  applications
- `scripts/odin_build.sh` - builds the core Odin binaries, Xspress Odin adapter
  and Python modules into a venv. This support optional arguments to build only
  certain components (useful for development). Use `-h` to see the options.
- `scripts/kill_odin.sh` - kills all Odin processes.

These scripts have optional arguments. Run them with `-h` to view the options
available - this includes building or rebuilding a subset of the components.

Note: these are also copied into the Docker image when built (see Docker image
section for more info).


Generating runtime configuration
================================

The Python module `pyxspress` can be used to generate the Odin runtime
configuration.

The Wheel is deployed when running the `copy_build_config.sh` script
and then built into a virtual environment that gets added to the user's
PATH when running `odin_build.sh`.

This means once these two scripts have been run you can call the entry
point from any location in your terminal. You can run with `-h` to see
the command line options.

.. code::

    xspress-create-config -h


Xspress binaries
================

This repository includes the Xspress binaries and headers required to build the
Xspress detector Odin adapter. This is because these aren't publically available
to download but are required by Odin to communicate with the Xspress system.

The `copy_build_config` script copies these binaries to `/odin/xspress`.


Setting up a new server
=======================

The following steps can be used to install Odin software on a new server:

1. Copy or clone this repository to the target server.
2. Run `./server/dependencies.sh` to install all dependencies
3. Run `./server/copy_build_config.sh` to set up the build
4. Run `/odin/scripts/odin_build.sh -a` to build all Odin components
5. Run `/odin/scripts/epics_build.sh -a` to build all EPICS components
6. Run `xspress-create-config` with the appropriate
   arguments based on Xspress system (use `-h` to see options)
7. Copy `./server/.bashrc_odin` to the home directory for `xspress3`
8. Source the `~/.bashrc_odin` file from `~/.bashrc` so that the Odin
   environment is set up automatically. See below for an example entry
   in `~/.bashrc`.

We can source the `~/.bashrc_odin` file using the following snippet in
the `~/.bashrc` file:

.. code:: bash

    # Include Odin bashrc
    if [ -f $HOME/.bashrc_odin ]; then
        . $HOME/.bashrc_odin
    fi


Launching Odin
==============

Launching the procServ processes can be done by running the 
`./server/launch_<N>chan_odin.sh` script. Here `<N>` will be replaced by the
number of channels you configured Odin with using the `copy_odin_config` script.

The procServ processes should then start and appear in `ps`:

.. code:: bash

    [xspress3@xspress3 qd-odin-build]$ ps -ef | grep -i procServ
    xspress3    4029    2399  0 Jul07 ?        00:00:05 procServ -P 4001 /odin/config/stOdinServer.sh
    xspress3    4031    2399  0 Jul07 ?        00:00:05 procServ -P 4002 /odin/config/stMetaWriter.sh
    xspress3    4033    2399  0 Jul07 ?        00:00:05 procServ -P 4003 /odin/config/stControlServer.sh
    xspress3    4035    2399  0 Jul07 ?        00:00:05 procServ -P 4004 /odin/config/stLiveViewMerge.sh
    xspress3    4037    2399  0 Jul07 ?        00:00:05 procServ -P 4005 /odin/config/stXspressADOdin.sh
    xspress3    4039    2399  0 Jul07 ?        00:00:05 procServ -P 4010 /odin/config/stFrameReceiver1.sh
    xspress3    4041    2399  0 Jul07 ?        00:00:05 procServ -P 4011 /odin/config/stFrameProcessor1.sh
    xspress3    4043    2399  0 Jul07 ?        00:00:05 procServ -P 4012 /odin/config/stFrameReceiver2.sh
    xspress3    4045    2399  0 Jul07 ?        00:00:05 procServ -P 4013 /odin/config/stFrameProcessor2.sh
    xspress3    4047    2399  0 Jul07 ?        00:00:05 procServ -P 9001 /odin/config/stProcServControl.sh
    xspress3    4049    2399  0 Jul07 ?        00:00:05 procServ -P 9002 /odin/config/stOdinProcServControl.sh



You can telnet to these processes to interact with them. See the port number
in the `-P` argument above to find the correct process:

.. code:: bash

    [xspress3@xspress3 qd-odin-build]$ telnet 127.0.0.1 9001
    Trying 127.0.0.1...
    Connected to 127.0.0.1.
    Escape character is '^]'.
    @@@ Welcome to procServ (procServ Process Server 2.7.0)
    @@@ Use ^X to kill the child, auto restart is ON, use ^T to toggle auto restart
    @@@ procServ server PID: 3824269
    @@@ Server startup directory: /home/xspress3/development/qd-odin-build
    @@@ Child startup directory: /home/xspress3/development/qd-odin-build
    @@@ Child started as: /odin/config/stProcServControl.sh
    @@@ Child "/odin/config/stProcServControl.sh" PID: 3825669
    @@@ procServ server started at: Mon Jul 22 14:50:33 2024
    @@@ Child "/odin/config/stProcServControl.sh" started at: Mon Jul 22 14:52:16 2024
    @@@ 0 user(s) and 0 logger(s) connected (plus you)

    telnet> q
    Connection closed.


The EDM GUI is launched using the following script:

.. code:: bash

    /odin/epics/support/ADOdin/iocs/xspress/bin/linux-x86_64/stxspress-gui


Stopping Odin
#############

You can stop Odin procServ processes by running the following script:

.. code:: bash

    /odin/scripts/kill_odin.sh


pyxspress
=========

The built Wheel for this module is deployed using the `copy_build_config.sh`
script. It is then installed in a dedicated virtual environment on the
target server using `odin_build.sh` at `/odin/util_python`.

This can be used to generated runtime configuration (see above) and also
includes some basic CLI and GUI tools to look at Xspress Odin data.

When installed the following entry points are available:

- `xspress-acquire`: basic MCA acquisition using ADOdin with file saving
- `xspress-plot`: basic MCA plotting of saved HDF5 data
- `xspress-view`: GUI application to browse MCA and list mode data
- `xspress-list-mode-listener`: can listen to X3X2 list mode TCP endpoints
  and save the binary data directly to disk.
- `xspress-list-mode-decode`: used to decode the saved list mode binary data
  and can either plot decoded time frames or save the data to a simpler HDF5
  format.


Acquisition script
##################

You can use the `-h` help argument to see what options are available:

.. code:: bash

    xspress3@xspress3 $ xspress-acquire -h
    Usage: xspress-acquire [OPTIONS]

    Run a basic internally-triggered acquisition and optionally save the data.

    Options:
    -i, --images INTEGER      Number of images  [default: 10]
    -t, --acquire_time FLOAT  Acquisition time per frame in seconds  [default:
                                0.1]
    -fd, --file_dir TEXT      File directory  [default: /data/odin-testing]
    -fn, --file_name TEXT     File name
    -pl, --plot               Enable plotting of some data
    -pa, --plot_all           Plot every image (caps out at 10 plots to avoid
                                sluggishness)
    -h, --help                Show this message and exit.


This will provide a plot or several plots showing the captured data.


Plotting script
###############

You can then run this as a script or module, shown below with the help argument
to print the list of options:

.. code:: bash

    xspress3@xspress3 $ xspress-plot -h
    Usage: xspress-plot [OPTIONS] FILENAME CHANNEL

    Plot the dataset for an Xspress channel

    Options:
    -af, --all_frames  Print all frames
    -h, --help         Show this message and exit.


.. note::
    If you have the Diamond HDF5 filters on your PATH then you can read the
    compressed data directly in the Python script. On Xspress servers this
    should be added by the `.bashrc_odin` bashrc file automatically:

    .. code:: bash

        export HDF5_PLUGIN_PATH=/odin/prefix/h5plugin

    Otherwise you will need to decompress the data before transferring it to
    another PC on a server with the filters installed. We can then decompress
    the datasets from `compressed.h5` into a new file `bloated.h5` using
    `h5repack`:

    .. code:: bash

        h5repack -f NONE compressed.h5 bloated.h5


Data viewer GUI
###############

A basic data viewer can be run using the following command:

.. code:: bash

    xspress3@xspress3 $ xspress-view


Docker image
============

The Dockerfile in the root of this repository builds a CentOS Stream 9 image with
the packages needed to build the Odin software components.

To build the Docker image:

.. code:: bash

    docker build -t odin-build:latest .

Or without using cache:

.. code:: bash

    docker build --no-cache -t odin-build:latest .


The container can be launched using the following command (leave out `--rm`
if you do not wish to delete the container when you exit its shell):

.. code:: bash

    docker run -it -p 8888:8888 --rm odin-build:latest


You can also launch it with this directory mounted.

Linux:

.. code:: bash

    docker run -it --rm -p=8888:8888 --volume=./:/qd-odin-build odin-build:latest

Windows:

.. code:: bash

    docker run -it --rm -p 8888:8888 -v $PWD/:/qd-odin-build odin-build:latest

.. note::

    The Python control server hosts a basic static web GUI on port 8888
