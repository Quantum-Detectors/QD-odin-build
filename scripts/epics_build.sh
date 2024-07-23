#!/usr/bin/bash

# ============================================================
# EPICS BUILD
# ============================================================
#
# This script builds the EPICS components required for Xspress
# Odin control via EPICS.
#

# Colours
CYAN="\033[0;36m"
GREEN="\033[1;32m"
RED="\033[0;31m"
NOCOL="\033[0m"

# Environment
EPICS_HOST_ARCH=linux-x86_64
HOST_ARCH=linux-x86_64


# ============================================================
# Directory setup
# ============================================================

# Root and install directories
root_dir=/odin
epics_dir=$root_dir/epics
epics_config_dir=$epics_dir/config
support_dir=$epics_dir/support

# Our versions of RELEASE files
release_local_file=$epics_config_dir/RELEASE.local
ioc_release_file=$epics_config_dir/xspress_IOC_RELEASE

echo -e "${RED}TARGET DIR: $epics_dir${NOCOL}"


# ============================================================
# EPICS base
# ============================================================

echo -e "${CYAN}BUILDING EPICS BASE${NOCOL}"

# Location
epics_base_dir=$epics_dir/epics-base

# Make sure we clone with the recursive tag or we don't get all components!
git clone --recursive https://github.com/epics-base/epics-base.git $epics_base_dir

cd $epics_base_dir
make -j 16
make install

echo -e "${GREEN}EPICS BASE COMPLETE${NOCOL}\n"


# ============================================================
# SynApps
# ============================================================

echo -e "${CYAN}BUILDING SUPPORT MODULES${NOCOL}"

# Directories
assemble_dir=$epics_dir/assemble

git clone https://github.com/EPICS-synApps/assemble_synApps.git $assemble_dir

# Run the assemble script and build
cd $assemble_dir
./assemble_synApps --config $epics_config_dir/synapp_modules --base $epics_base_dir --dir $epics_dir
cd $support_dir
make -j 16

echo -e "${GREEN}SUPPORT MODULES COMPLETE${NOCOL}\n"


# ============================================================
# Rest client
# ============================================================

echo -e "${CYAN}BUILDING RESTCLIENT${NOCOL}"

# Directories
rest_client_dir=$support_dir/restClient

git clone https://github.com/Quantum-Detectors/restClient.git $rest_client_dir

cd $rest_client_dir
# TODO: remove when merged into default qd-main branch
git checkout feature/qd-build
make

echo -e "${GREEN}RESTCLIENT COMPLETE${NOCOL}\n"


# ============================================================
# ADOdin
# ============================================================

echo -e "${CYAN}BUILDING ADODIN${NOCOL}"

# Directories
adodin_dir=$support_dir/ADOdin

git clone https://github.com/Quantum-Detectors/ADOdin.git $adodin_dir

cd $adodin_dir
# TODO: remove when merged into default qd-main branch
git checkout feature/qd-build
make

echo -e "${GREEN}ADODIN COMPLETE${NOCOL}\n"


# ============================================================
# EPICS extensions
# ============================================================

echo -e "${CYAN}BUILDING EPICS EXTENSIONS${NOCOL}"

# Directories
extensions_dir=$epics_dir/extensions
extensions_src_dir=$extensions_dir/src
edm_dir=$extensions_src_dir/edm

git clone https://github.com/epics-extensions/extensions.git $extensions_dir
git clone https://github.com/gnartohl/edm.git $edm_dir

# Make extensions
cd $extensions_dir

# Need to copy our RELEASE.local file for EPICS base
cp $release_local_file $extensions_dir/configure
# Add EDM to list of extensions to build
sed -i 's@DIRS := $(wildcard $(DIRS))@DIRS += edm\n\nDIRS := $(wildcard $(DIRS))@' src/Makefile

make

echo -e "${CYAN}CONFIGURING EDM${NOCOL}"

# Configure EDM paths
edm_objects_dir=$epics_dir/edm
edm=$extensions_dir/bin/$EPICS_HOST_ARCH/edm
mkdir $edm_objects_dir

# EDM macros
export EDMOBJECTS=$edm_objects_dir
export EDMPVOBJECTS=$edm_objects_dir
export EDMHELPFILES=$edm_objects_dir/helpFiles
export EDMFILES=$edm_objects_dir
export EDMDATAFILES=$edm_objects_dir  # This will get replaced by the start GUI scripts

# EDM objects (use edm -show on the libraries to check)
$edm -add $extensions_dir/lib/linux-x86_64/libEdmBase.so
$edm -add $extensions_dir/lib/linux-x86_64/lib57d79238-2924-420b-ba67-dfbecdf03fcd.so
$edm -add $extensions_dir/lib/linux-x86_64/lib7e1b4e6f-239d-4650-95e6-a040d41ba633.so
$edm -add $extensions_dir/lib/linux-x86_64/libcf322683-513e-4570-a44b-7cdd7cae0de5.so
$edm -add $extensions_dir/lib/linux-x86_64/libEdmDiamond.so
$edm -add $extensions_dir/lib/linux-x86_64/libTriumf.so
$edm -add $extensions_dir/lib/linux-x86_64/libIndicator.so
$edm -add $extensions_dir/lib/linux-x86_64/libMultSegRamp.so
$edm -add $extensions_dir/lib/linux-x86_64/libPV.so
$edm -add $extensions_dir/lib/linux-x86_64/libSlac.so
$edm -add $extensions_dir/lib/linux-x86_64/libTwoDProfileMonitor.so

# EDM PV objects (use edm -showpv on the libraries to check)
$edm -addpv $extensions_dir/lib/linux-x86_64/libEpics.so
$edm -addpv $extensions_dir/lib/linux-x86_64/libCalc.so
$edm -addpv $extensions_dir/lib/linux-x86_64/libLoc.so
$edm -addpv $extensions_dir/lib/linux-x86_64/libLog.so
$edm -addpv $extensions_dir/lib/linux-x86_64/libProxy.so

# Boilerplate print definition and help files
cp $extensions_dir/src/edm/edmMain/edmPrintDef $edm_objects_dir
cp -r $extensions_dir/src/edm/helpFiles $edm_objects_dir

echo -e "${GREEN}EPICS EXTENSIONS COMPLETE${NOCOL}\n"


# ============================================================
# procServControl
# ============================================================

# This module is primarily used for the EDM screens. The actual IOC will be a
# Python softIOC using the odinprocservcontrol module.

echo -e "${CYAN}BUILDING PROCSERVCONTROL${NOCOL}"

# Directories
procServControl_dir=$support_dir/procServControl
procServControl_RELEASE_local=$procServControl_dir/configure/RELEASE.local
procServControl_RELEASE=$procServControl_dir/configure/RELEASE
procServControl_ioc_RELEASE=$procServControl_dir/iocs/autoProcServControl/configure/RELEASE
procServControl_ioc_RELEASE_local=$procServControl_dir/iocs/autoProcServControl/configure/RELEASE.local

git clone https://github.com/dls-controls/procServControl.git $procServControl_dir

cd $procServControl_dir

# Set up the module configure files
# Override the RELEASE file macros with our local version
echo '-include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
# Need to apply our RELEASE.local file to the module configuration
cp $release_local_file $procServControl_RELEASE_local
# Don't try and build the Diamond XML builder IOC
sed -i 's@DIRS := .*$(wildcard etc))@@' Makefile

# Set up the IOC configure files
# Override the RELEASE file for the example IOC with our local version
echo '-include $(TOP)/configure/RELEASE.local' > $procServControl_ioc_RELEASE
# Need to apply our RELEASE.local file to the IOC configuration
cp $release_local_file $procServControl_ioc_RELEASE_local

make

echo -e "${GREEN}PROCSERVCONTROL COMPLETE${NOCOL}\n"
