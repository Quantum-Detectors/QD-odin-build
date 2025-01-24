QD Odin build
-------------

This repository contains build files used to build the Odin software components
for Xspress readout systems.


Repository layout
=================

This repository contains the following components:

- adodin-config: Configuration files for ADOdin EPICS module
- edm-config: EDM configuration files
- epics-config: General EPICS configuration files
- odin-config: Odin runtime configuration files
- python: Python module for testing and using ADOdin
- scripts: Build scripts for Odin and EPICS
- server: Utility scripts for deploying onto a server


Build scripts
=============

These are in the `scripts/` directory and are used to build all of the software
components required for Odin and related software.

- `scripts/epics_build.sh` - builds EPICS base and related modules and
  applications
- `scripts/odin_build.sh` - builds the core Odin binaries, Xspress Odin adapter
  and Python modules into a venv. This support optional arguments to build only
  certain components (useful for development). Use `-h` to see the options.

These scripts have optional arguments. Run them with `-h` to view the options
available - this includes building or rebuilding a subset of the components.

Note: these are also copied into the Docker image when built (see Docker image
section for more info).


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
- `server/copy_odin_config.sh` - copies the Odin runtime configuration files
  matching the target system. Run with `-h` to see the available arguments.
- `server/dependencies.sh` - installs the dependencies required to build and
  run the Odin and related software

Note: the `dependencies` script should be run before trying to build the
software


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
4. Run `./odin/odin_build.sh` to build Odin components
5. Run `./odin/epics_build.sh` to build the EPICS components
6. Run `./server/copy_odin_config.sh` with the correct arguments to set up the
   Odin runtime config - run with `-h` for more info.
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
    xspress3 3823260       1  0 14:49 ?        00:00:00 procServ -P 4001 /odin/config/stOdinServer.sh
    xspress3 3823263       1  0 14:49 ?        00:00:00 procServ -P 4002 /odin/config/stFrameReceiver1.sh
    xspress3 3823266       1  0 14:49 ?        00:00:00 procServ -P 4003 /odin/config/stFrameProcessor1.sh
    xspress3 3823269       1  0 14:49 ?        00:00:00 procServ -P 4004 /odin/config/stFrameReceiver2.sh
    xspress3 3823272       1  0 14:49 ?        00:00:00 procServ -P 4005 /odin/config/stFrameProcessor2.sh
    xspress3 3823275       1  0 14:49 ?        00:00:00 procServ -P 4006 /odin/config/stMetaWriter.sh
    xspress3 3823278       1  0 14:49 ?        00:00:00 procServ -P 4007 /odin/config/stControlServer.sh
    xspress3 3823281       1  0 14:49 ?        00:00:00 procServ -P 4008 /odin/config/stLiveViewMerge.sh
    xspress3 3824263       1  0 14:50 ?        00:00:00 procServ -P 4009 /odin/config/stXspressADOdin.sh
    xspress3 3824269       1  0 14:50 ?        00:00:00 procServ -P 9001 /odin/config/stProcServControl.sh
    xspress3 3824266       1  0 14:50 ?        00:00:00 procServ -P 9002 /odin/config/stOdinProcServControl.sh


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


Python test module
==================

There is a python module at `python/src/pyxspress` which can be used to test
some basic functionality.

When installed the following entry points are available:

- `xspress-acquire`: basic MCA acquisition using ADOdin with file saving
- `xspress-plot`: basic MCA plotting of saved HDF5 data
- `xspress-view`: GUI application to browse MCA HDF5 data
- `xspress-list-mode-listener`: can listen to X3X2 list mode TCP endpoints
  and save the binary data directly to disk.
- `xspress-list-mode-decode`: used to decode the saved list mode binary data
  and can either plot decoded time frames or save the data to a simpler HDF5
  format.

You can use `pipenv` to create the Python virtual environment. Make sure you
are in the `./python` folder of this repository before running!

For example, setting up the environment and launching an entry point:

.. code:: bash

    ben@alyx qd-odin-build/python $ pipenv install --dev
    ben@alyx qd-odin-build/python $ pipenv run xspress-view

.. note::

    For plotting you will also need Qt for the Matplotlib GUI. The current
    version uses Qt5. This can be installed using your standard package
    manager.


Acquisition script
##################

You can use the `-h` help argument to see what options are available:

.. code:: bash

    ben@Alyx qd-odin-build/python $ pipenv run xspress-acquire -h
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

    python python/plot_data.py --help
    python -m python.plot_data --help


An example dummy file is included at `python/testing/example_A_file.h5`. This
can be used as a test to make sure the application is working:

.. code:: bash

    ben@Alyx qd-odin-build/python $ pipenv run xspress-plot ./testing/example_A_file.h5
    Reading dataset mca_0 from ./example_A_file.h5
    Available datasets: ['data', 'mca_0', 'mca_1', 'mca_2', 'mca_3']
    Got data of shape: (10, 1, 4096)
    Plotting first frame only
    Index of maximum: 1985


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
