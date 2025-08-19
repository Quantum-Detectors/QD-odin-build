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
sudo chown xspress3 /odin
sudo chgrp xspress3 /odin

# EPICS configuration files
echo -e "${CYAN}Copying EPICS build configuration files${NOCOL}"
mkdir -p /odin/epics/config
cp $root_dir/config/epics/synapp_modules /odin/epics/config
cp $root_dir/config/epics/RELEASE.local /odin/epics/config
cp $root_dir/config/epics/xspress_IOC_RELEASE /odin/epics/config

# EDM configuration files
echo -e "${CYAN}Copying EDM configuration files${NOCOL}"
mkdir -p /odin/epics/edm
cp $root_dir/config/edm/colors.list /odin/epics/edm
cp $root_dir/config/edm/fonts.list /odin/epics/edm

# Xspress binaries
echo -e "${CYAN}Copying Xspress binaries${NOCOL}"
cp -r $root_dir/xspress /odin

# Copy build and utility scripts
echo -e "${CYAN}Copying scripts${NOCOL}"
mkdir -p /odin/scripts
cp $root_dir/scripts/*.sh /odin/scripts/

# Build and copy Python config wheel
echo -e "${CYAN}Building and deploying pyxspress${NOCOL}"
module_path=$root_dir/python

# Generate the wheel
rm -rf conf_venv
python3.11 -m venv conf_venv/
source conf_venv/bin/activate
pip install --upgrade pip
pip install build
cd $module_path
python -m build -w .
deactivate

# Remove the build environment
cd ..
rm -rf conf_venv/

# Copy the Wheel
mkdir -p /odin/util_wheels/
cp $module_path/dist/*.whl /odin/util_wheels/

echo -e "${GREEN}Configuration copied successfully${NOCOL}\n"
