#!/usr/bin/bash

# ============================================================
# Copy build config
# ============================================================
#
# This copies the build configuration to the /odin root folder so that
# the build scripts in /scripts can be run.
#
# This will need root access to create the top-level directory /odin.
#
# This copies:
# - Generic EPICS configuration files to /odin/epics/config
# - Xspress binaries to /odin/xspress
# - Build scripts to /odin/odin_build.sh and /odin/epics/epics_build.sh
#
# The owner of the directory will be xspress3.
#

# Get the parent directory
script_dir="$( cd "$( dirname "$0" )" && pwd )"
root_dir="$(dirname $script_dir)"

# Directories
sudo mkdir -p /odin
sudo chown xspress3 /odin
sudo chgrp xspress3 /odin

# EPICS configuration files
mkdir -p /odin/epics/config
cp $root_dir/epics-config/synapp_modules /odin/epics/config
cp $root_dir/epics-config/RELEASE.local /odin/epics/config
cp $root_dir/epics-config/xspress_IOC_RELEASE /odin/epics/config

# EDM configuration files
mkdir -p /odin/epics/edm
cp $root_dir/edm-config/colors.list /odin/epics/edm
cp $root_dir/edm-config/fonts.list /odin/epics/edm

# Xspress binaries
cp -r $root_dir/xspress /odin

# Build scripts
cp $root_dir/scripts/odin_build.sh /odin
cp $root_dir/scripts/epics_build.sh /odin/epics

# Ownership
chown -R xspress3 /odin
chgrp -R xspress3 /odin
