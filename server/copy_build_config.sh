#!/usr/bin/bash

# ============================================================
# Copy build config
# ============================================================
#
# THIS SHOULD BE RUN AS ROOT SO THE TOP-LEVEL DIRECTORY CAN BE CREATED
#
# This copies the build configuration to the /odin root folder so that
# the build scripts in /scripts can be run.
#
# This copies:
# - EPICS configuration files to /odin/epics/config
# - Xspress binaries to /odin/xspress
# - Build scripts to /odin/odin_build.sh and /odin/epics/epics_build.sh
#
# The owner of the directory will be xspress3.
#

# Directories
mkdir -p /odin
chown xspress3 /odin
chgrp xspress3 /odin

# EPICS configuration files
mkdir -p /odin/epics/config
cp epics/synapp_modules /odin/epics/config
cp epics/RELEASE.local /odin/epics/config
cp epics/xspress_IOC_RELEASE /odin/epics/config

# EDM configuration files
mkdir -p /odin/epics/edm
cp edm-config/colors.list /odin/epics/edm
cp edm-config/fonts.list /odin/epics/edm

# Xspress binaries
cp -r xspress /odin/xspress

# Build scripts
cp scripts/odin_build.sh /odin
cp scripts/epics_build.sh /odin/epics

# Ownership
chown -R xspress3 /odin
chgrp -R xspress3 /odin
