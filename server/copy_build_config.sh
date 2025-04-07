#!/usr/bin/bash
exec > /dev/null 2>&1
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
cp $root_dir/config/epics/synapp_modules /odin/epics/config
cp $root_dir/config/epics/RELEASE.local /odin/epics/config
cp $root_dir/config/epics/xspress_IOC_RELEASE /odin/epics/config

# EDM configuration files
mkdir -p /odin/epics/edm
cp $root_dir/config/edm/colors.list /odin/epics/edm
cp $root_dir/config/edm/fonts.list /odin/epics/edm

# Xspress binaries
cp -r $root_dir/xspress /odin

# Build scripts
cp $root_dir/scripts/odin_build.sh /odin
cp $root_dir/scripts/epics_build.sh /odin/epics

# Build config wheel
module_path=$root_dir/python

rm -rf conf_venv

python3.11 -m venv conf_venv/
source conf_venv/bin/activate
pip install --upgrade pip
pip install build

cd $module_path
python -m build 

deactivate

cd ..
rm -rf conf_venv/

sudo mkdir -p /odin/python/conf
cp $module_path/dist/*.whl /odin/python/conf

# Ownership
chown -R xspress3 /odin
chgrp -R xspress3 /odin
