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

# Colours
CYAN="\033[0;36m"
GREEN="\033[1;32m"
RED="\033[0;31m"
NOCOL="\033[0m"

# Get the parent directory
script_dir="$( cd "$( dirname "$0" )" && pwd )"
root_dir="$(dirname $script_dir)"

# Directories
echo -e "${CYAN}Creating deployment directories${NOCOL}"
sudo mkdir -p /odin
sudo chown $USER /odin
sudo chgrp $USER /odin

# EPICS configuration files
echo -e "${CYAN}Copying EPICS build configuration files${NOCOL}"
mkdir -p /odin/epics/config
cp $root_dir/epics_config/synapp_modules /odin/epics/config
cp $root_dir/epics_config/RELEASE.local /odin/epics/config
cp $root_dir/epics_config/xspress_IOC_RELEASE /odin/epics/config

# EDM configuration files
echo -e "${CYAN}Copying EDM configuration files${NOCOL}"
mkdir -p /odin/epics/edm
cp $root_dir/edm_config/colors.list /odin/epics/edm
cp $root_dir/edm_config/fonts.list /odin/epics/edm

# Xspress binaries
echo -e "${CYAN}Copying Xspress binaries${NOCOL}"
# Make sure old binaries are deleted
rm -rf /odin/xspress
cp -r $root_dir/xspress /odin/xspress

# Copy build and utility scripts
echo -e "${CYAN}Copying scripts${NOCOL}"
mkdir -p /odin/scripts
cp $root_dir/scripts/*.sh /odin/scripts/

# Copy the pyxspress Wheel
echo -e "${CYAN}Copying pyxspress Wheel${NOCOL}"
mkdir -p /odin/util_wheels/
# Make sure old wheels are deleted
rm -f /odin/util_wheels/*.whl
cp $root_dir/wheels/*.whl /odin/util_wheels/

# Tools
echo -e "${CYAN}Copying tools${NOCOL}"
# Make sure old tools are deleted
rm -rf /odin/tools
cp -r $root_dir/tools /odin/tools

echo -e "${GREEN}Configuration copied successfully${NOCOL}\n"
