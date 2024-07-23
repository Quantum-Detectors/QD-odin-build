QD Odin build
-------------

This repository contains build files used to build the Odin software components
for Xspress readout systems.


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


Build scripts
=============

Scripts from the `scripts/` directory are copied into the Docker container when
built.

- `scripts/epics_build.sh` - builds EPICS base and related modules and
  applications for Odin
- `scripts/odin_build.sh` - builds the core Odin binaries, Xspress Odin adapter
  and Python modules into a venv


Server scripts
==============

Scripts in the `server/` directory can be run from the root of this repository.
They are for running on Xspress servers to install dependencies and copy the
configuration from this repository to the /odin directory.

The following scripts are available:

- `server/copy_config.sh` - copies the scripts and configuration from this repo
  to the same directories as done in the Dockerfile. Should be run after
  `dependencies.sh`
- `server/dependencies.sh` - installs all Odin, EPICS and Xspress dependencies


Xspress binaries
================

This repository includes the Xspress binaries and headers required to build the
Xspress detector Odin adapter. This is because these aren't publically available
to download.

This folder should be copied to the following location (if not using Docker):

.. code::

    /odin/xspress

The Docker image has the xspress folder copied to `/odin/xspress` when built.


Setting up a new server
=======================

The following steps can be used to install Odin software on a new server:

1. Clone this repository (or copy the contents) somewhere on the server
2. Run `./server/dependencies.sh` to install package dependencies
3. Run `sudo ./server/copy_build_config.sh` to create the Odin directories and
   the build configuration files
4. Run `./server/copy_odin_config.sh` to copy the runtime configuration files
5. Run `./odin/odin_build.sh` to build Odin and related packages
6. Run `./odin/epics_build.sh` to build EPICS base, support modules and ADOdin
7. Copy the bashrc file `./server/.bashrc_odin` to home (`~/`)
8. Add `~/.bashrc_odin` to the base bashrc file (e.g. `~/.bashrc`) - see below

.. code:: bash

    # Include Odin bashrc
    if [ -f $HOME/.bashrc_odin ]; then
        . $HOME/.bashrc_odin
    fi


Launching Odin
==============

Launching the procServ processes can be done by running the 
`./server/launch_8chan_odin.sh` script. This is only compatible with an 8
channel system.

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


Plotting data
=============

There is an example Python script in `./python` which can be used to plot
output data from Odin.

You can set up a virtual environment with the dependencies required:

.. code:: bash

    python -m venv test_venv
    source test_venv/bin/activate
    pip install -r python/requirements.txt


You can then run it as a script or module, shown below with the help argument
to print the list of options:

.. code:: bash

    python python/plot_data.py --help
    python -m python.plot_data --help


An example dummy file is included at `python/example_A_file.h5`. This can be
used as a test to make sure the application is working:

.. code:: bash

    (test_venv) ben@Alyx ~/qd-odin-build $ python python/plot_data.py python/example_A_file.h5 2 -af
    Reading dataset mca_2 from python/example_A_file.h5
    Available datasets: ['data', 'mca_0', 'mca_1', 'mca_2', 'mca_3']
    Got data of shape: (10, 1, 4096)
    Plotting all frames
    Frame 0 index of maximum: 1985
    Frame 1 index of maximum: 1985
    Frame 2 index of maximum: 1985
    Frame 3 index of maximum: 1985
    Frame 4 index of maximum: 1985
    Frame 5 index of maximum: 1985
    Frame 6 index of maximum: 1985
    Frame 7 index of maximum: 1985
    Frame 8 index of maximum: 1985
    Frame 9 index of maximum: 1985


.. note::

    You first need to decompress any compressed Odin data files as it cannot
    currently read from compressed datasets.

    First make sure you have the Diamond HDF5 filters on your path. This only
    needs to be done if the `.bashrc_odin` file is not already loaded by your
    top-level bashrc file (the following example is based on using the install
    scripts in this repo):

    .. code:: bash

        export HDF5_PLUGIN_PATH=/odin/prefix/h5plugin

    Now we can decompress the datasets from `compressed.h5` into a new file
    `bloated.h5`:

    .. code:: bash

        h5repack -f NONE compressed.h5 bloated.h5

    The python script can then be used
