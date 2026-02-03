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
# Parse user args
# ============================================================

build_epics_base=false
build_syn_apps=false
build_rest_client=false
build_adodin=false
build_epics_extensions=false
build_procServControl=false

# Check at least one thing was chosen
build_any=false

options=":aesroxph"

while getopts ${options} flag
do
    case ${flag} in
        a)
            # Build all
            build_epics_base=true
            build_syn_apps=true
            build_rest_client=true
            build_adodin=true
            build_epics_extensions=true
            build_procServControl=true
            build_any=true
            ;;
        e)
            build_epics_base=true
            build_any=true
            ;;
        s)
            build_syn_apps=true
            build_any=true
            ;;
        r)
            build_rest_client=true
            build_any=true
            ;;
        o)
            build_adodin=true
            build_any=true
            ;;
        x)
            build_epics_extensions=true
            build_any=true
            ;;
        p)
            build_procServControl=true
            build_any=true
            ;;
        h)
            echo ""
            echo -e "${CYAN}================================================================================${NOCOL}"
            echo "EPICS build script"
            echo -e "${CYAN}================================================================================${NOCOL}"
            echo ""
            echo "This script downloads EPICS and related software for Xspress Odin."
            echo ""
            echo "Notes:"
            echo "  - if updating EPICS base version then you should rebuild everything."
            echo "  - if updating synapps version then rebuild synApps modules and ADOdin."
            echo "  - if rebuilding ADOdin then you need to copy the runtime Odin configuration again using"
            echo "    ./server/copy_odin_config.sh from the QD Odin build repository. This will be improved"
            echo "    in the future"
            echo ""
            echo "Choose from the following options:"
            echo ""
            echo "    -a : build all components"
            echo "    -e : build EPICS base"
            echo "    -s : build synapps"
            echo "    -r : build restClient"
            echo "    -o : build ADOdin"
            echo "    -x : EPICS extensions"
            echo "    -p : Build procServControl"
            echo "    -h : print this help message and exit."
            echo ""
            echo -e "${CYAN}================================================================================${NOCOL}"
            echo ""
            exit 0
            ;;
        ?)
            echo "ERROR: Invalid option '${OPTARG}'. Type -h for help"
            exit 1
            ;;
    esac
done

if [[ $build_any == false ]]
then
    echo "ERROR: No build options selected. Type -h for help"
    exit 1
fi

echo -e "${CYAN}=======================================================${NOCOL}"
echo "Selected components"
echo -e "${CYAN}=======================================================${NOCOL}"
if [[ $build_epics_base == true ]]
then
    echo -e " - EPICS Base: ${GREEN}$build_epics_base${NOCOL}"
else
    echo -e " - EPICS Base: $build_epics_base"
fi
if [[ $build_syn_apps == true ]]
then
    echo -e " - EPICS synapps: ${GREEN}$build_syn_apps${NOCOL}"
else
    echo -e " - EPICS synapps: $build_syn_apps"
fi
if [[ $build_rest_client == true ]]
then
    echo -e " - Rest client: ${GREEN}$build_rest_client${NOCOL}"
else
    echo -e " - Rest client: $build_rest_client"
fi
if [[ $build_adodin == true ]]
then
    echo -e " - ADOdin: ${GREEN}$build_adodin${NOCOL}"
else
    echo -e " - ADOdin: $build_adodin"
fi
if [[ $build_epics_extensions == true ]]
then
    echo -e " - EPICS extensions: ${GREEN}$build_epics_extensions${NOCOL}"
else
    echo -e " - EPICS extensions: $build_epics_extensions"
fi
if [[ $build_procServControl == true ]]
then
    echo -e " - procServControl: ${GREEN}$build_procServControl${NOCOL}"
else
    echo -e " - procServControl: $build_procServControl"
fi
echo -e "${CYAN}=======================================================${NOCOL}"


# ============================================================
# Directory setup
# ============================================================

# Root and install directories
root_dir=/odin
epics_dir=$root_dir/epics
epics_base_dir=$epics_dir/epics-base
epics_config_dir=$epics_dir/config
support_dir=$epics_dir/support

# Our versions of RELEASE files
release_local_file=$epics_config_dir/RELEASE.local
ioc_release_file=$epics_config_dir/xspress_IOC_RELEASE

echo -e "\nTARGET DIR: ${GREEN}$epics_dir${NOCOL}\n"


# ============================================================
# EPICS base
# ============================================================

if [[ $build_epics_base == true ]]
then
    echo -e "${CYAN}BUILDING EPICS BASE${NOCOL}"

    # Clean out existing install
    rm -rf $epics_base_dir

    # Make sure we clone with the recursive tag or we don't get all components!
    git clone --recursive https://github.com/epics-base/epics-base.git $epics_base_dir

    cd $epics_base_dir
    make -j 16
    make install

    echo -e "${GREEN}EPICS BASE COMPLETE${NOCOL}\n"
fi

# ============================================================
# SynApps
# ============================================================

if [[ $build_syn_apps == true ]]
then
    echo -e "${CYAN}BUILDING SUPPORT MODULES${NOCOL}"

    # Directories
    assemble_dir=$epics_dir/assemble

    # Clean out existing checkout
    rm -rf $assemble_dir

    git clone https://github.com/EPICS-synApps/assemble_synApps.git $assemble_dir

    # Run the assemble script and build
    cd $assemble_dir
    ./assemble_synApps --config $epics_config_dir/synapp_modules --base $epics_base_dir --dir $epics_dir
    cd $support_dir
    make -j 16

    echo -e "${GREEN}SUPPORT MODULES COMPLETE${NOCOL}\n"
fi


# ============================================================
# Rest client
# ============================================================

if [[ $build_rest_client == true ]]
then
    echo -e "${CYAN}BUILDING RESTCLIENT${NOCOL}"

    # Directories
    rest_client_dir=$support_dir/restClient
    rest_client_tar="restClient.tar.gz"

    # Make sure directory is clean
    cd $support_dir
    rm -rf $rest_client_dir
    rm -f $rest_client_tar

    # Get release
    wget https://github.com/Quantum-Detectors/restClient/archive/refs/tags/0-2qd1-0.tar.gz -O $rest_client_tar

    # Extract
    mkdir $rest_client_dir
    tar -xzf $rest_client_tar -C $rest_client_dir --strip-components=1
    rm -f $rest_client_tar

    # Build
    cd $rest_client_dir
    make

    echo -e "${GREEN}RESTCLIENT COMPLETE${NOCOL}\n"
fi


# ============================================================
# ADOdin
# ============================================================

if [[ $build_adodin == true ]]
then
    echo -e "${CYAN}BUILDING ADODIN${NOCOL}"

    # Directories
    adodin_dir=$support_dir/ADOdin
    adodin_tar="ADOdin.tar.gz"

    # Clean out
    cd $support_dir
    rm -rf $adodin_dir
    rm -f $adodin_tar

    # Get release
    wget https://github.com/Quantum-Detectors/ADOdin/archive/refs/tags/0-10-4qd1-4.tar.gz -O $adodin_tar

    # Extract
    mkdir $adodin_dir
    tar -xzf $adodin_tar -C $adodin_dir --strip-components=1
    rm -f $adodin_tar

    # Check if we have a specific substitutions file configured for us to use
    source_db_sub_file=/odin/epics/config/xspress_expanded.substitutions
    if [[ -f $source_db_sub_file ]]
    then
        echo -e "${GREEN}[INFO]${NOCOL} Copying specific ADOdin IOC template from $source_db_sub_file"
        db_sub_target_adodin_dir=$adodin_dir/iocs/xspress/xspressApp/Db/$db_sub_target_filename
        cp $source_db_sub_file $db_sub_target_adodin_dir
    fi

    # Build
    cd $adodin_dir
    make

    echo -e "${GREEN}ADODIN COMPLETE${NOCOL}\n"
fi


# ============================================================
# EPICS extensions
# ============================================================

if [[ $build_epics_extensions == true ]]
then
    echo -e "${CYAN}BUILDING EPICS EXTENSIONS${NOCOL}"

    # Directories
    extensions_dir=$epics_dir/extensions
    extensions_src_dir=$extensions_dir/src
    edm_dir=$extensions_src_dir/edm

    edm_tar=edm.tar.gz

    # Clean out
    rm -rf $extensions_dir

    git clone https://github.com/epics-extensions/extensions.git $extensions_dir

    # Check out commit as we don't have recent release
    cd $extensions_dir
    git checkout ce3af4c9d82e6a34d788aa907dbc5ad0d7e29df1

    # Change to directory where EDM will be stored
    cd $extensions_src_dir

    # Get EDM release
    wget https://github.com/Quantum-Detectors/edm/archive/refs/tags/V1-12-105Q.tar.gz -O $edm_tar

    # Extract EDM
    mkdir $edm_dir
    tar -xzf $edm_tar -C $edm_dir --strip-components=1
    rm -f $edm_tar

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

    # Clean EDM object files (we re-create these below)
    rm -f $edm_objects_dir/edmObjects
    rm -f $edm_objects_dir/edmPvObjects

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
fi


# ============================================================
# procServControl
# ============================================================

# This is for the procServControl IOC to provide PVs for controlling the Odin
# processes running under procServ. A Python Odin soft IOC will be used to
# control the starting and stopping of these processes via these PVs in a
# controlled order.

if [[ $build_procServControl == true ]]
then
    echo -e "${CYAN}BUILDING PROCSERVCONTROL${NOCOL}"

    # Directories
    procServControl_dir=$support_dir/procServControl
    procServControl_RELEASE_local=$procServControl_dir/configure/RELEASE.local
    procServControl_RELEASE=$procServControl_dir/configure/RELEASE
    procServControl_ioc_RELEASE=$procServControl_dir/iocs/autoProcServControl/configure/RELEASE
    procServControl_ioc_RELEASE_local=$procServControl_dir/iocs/autoProcServControl/configure/RELEASE.local

    procServControl_tar=procServControl.tar.gz

    # Clean out before rebuilding
    cd $support_dir
    rm -rf $procServControl_dir
    rm -f $procServControl_tar

    # Get release
    wget https://github.com/DiamondLightSource/procServControl/archive/refs/tags/1-23.tar.gz -O $procServControl_tar

    # Extract
    mkdir $procServControl_dir
    tar -xzf $procServControl_tar -C $procServControl_dir --strip-components=1
    rm -f $procServControl_tar

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
fi

echo -e "${CYAN}EPICS BUILD COMPLETE${NOCOL}\n"
