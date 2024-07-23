#!/usr/bin/bash

# ============================================================
# Copy Odin runtime config
# ============================================================
#
# This copies the configuration files needed to run the applications.
#
# This copies:
# - Odin Xspress 3 8 channel config to /odin/
#

# Odin configuration directory
mkdir -p /odin/config
cp -r odin-config/xspress3/* /odin/config
