#!/usr/bin/bash

# ============================================================
# ODIN BUILD
# ============================================================
#
# This script builts the core Odin software components.
# This does not include any EPICS modules.
#

# Colours
CYAN="\033[0;36m"
GREEN="\033[1;32m"
RED="\033[0;31m"
NOCOL="\033[0m"


# ============================================================
# Parse user args
# ============================================================

build_odin_data=false
build_xspress_detector=false
build_hdf5_filters=false
build_python_env=false
build_config_env=false

# Check at least one thing was chosen
build_any=false

# Don't delete and re-check out
build_in_place=false

options=":adxfpich"

while getopts ${options} flag
do
    case ${flag} in
        a)
            build_odin_data=true
            build_xspress_detector=true
            build_hdf5_filters=true
            build_python_env=true
            build_any=true
            build_config_env=true
            ;;
        d)
            build_odin_data=true
            build_any=true
            ;;
        x)
            build_xspress_detector=true
            build_any=true
            ;;
        f)
            build_hdf5_filters=true
            build_any=true
            ;;
        p)
            build_python_env=true
            build_any=true
            ;;
        i)
            build_in_place=true
            ;;
        c)
            build_config_env=true
            build_any=true
            ;;
        h)
            echo ""
            echo -e "${CYAN}=======================================================${NOCOL}"
            echo "Odin build script"
            echo -e "${CYAN}=======================================================${NOCOL}"
            echo ""
            echo "This script downloads the Odin software components and builds them"
            echo "into The Odin prefix directory. Existing software will be replaced"
            echo "if chosen to be rebuilt."
            echo ""
            echo "Note: if rebuilding Odin data then Xspress detector may also need"
            echo "to be rebuilt."
            echo ""
            echo "Choose from the following options:"
            echo ""
            echo "    -a : build all components"
            echo "    -d : build Odin data"
            echo "    -x : build Xspress detector"
            echo "    -f : build Diamond HDF5 filters"
            echo "    -p : build the Python environment and Odin Python components"
            echo "    -i : rebuild C++ components in place (without re-fetching release)"
            echo "    -c : build the configuration enviroment"
            echo "    -h : print this help message and exit."
            echo ""
            echo -e "${CYAN}=======================================================${NOCOL}"
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
if [[ $build_odin_data == true ]]
then
    echo -e " - Odin data: ${GREEN}$build_odin_data${NOCOL}"
else
    echo -e " - Odin data: $build_odin_data"
fi
if [[ $build_xspress_detector == true ]]
then
    echo -e " - Xspress detector: ${GREEN}$build_xspress_detector${NOCOL}"
else
    echo -e " - Xspress detector: $build_xspress_detector"
fi
if [[ $build_hdf5_filters == true ]]
then
    echo -e " - Diamond HDF5 filters: ${GREEN}$build_hdf5_filters${NOCOL}"
else
    echo -e " - Diamond HDF5 filters: $build_hdf5_filters"
fi
if [[ $build_python_env == true ]]
then
    echo -e " - Python components: ${GREEN}$build_python_env${NOCOL}"
else
    echo -e " - Python components: $build_python_env"
fi
if [[ $build_config_env == true ]]
then
    echo -e " - Python config environment: ${GREEN}$build_config_env${NOCOL}"
else
    echo -e " - Python config environment: $build_config_env"
fi
echo -e "${CYAN}=======================================================${NOCOL}\n"


# ============================================================
# Directory setup
# ============================================================

# Root and install directories
root_dir=/odin
prefix_dir=$root_dir/prefix

echo -e "TARGET INSTALL DIR: ${GREEN}$prefix_dir${NOCOL}"
echo -e "BUILDING IN PLACE: ${GREEN}$build_in_place${NOCOL}\n"

# Xspress binaries root directory
xspress_name=xspress
xspress_dir=$root_dir/$xspress_name

# Xspress libary names
xspress_lib_name=libxspress3.so.1.0.0
imgmod_lib_name=libimg_mod.so.1.0.0

# Xspress library and header location relative to Xspress root
xspress_inc_dir=$xspress_dir/include
xspress_lib_dir=$xspress_dir/lib
xspress_lib=$xspress_lib_dir/$xspress_lib_name
imgmod_lib=$xspress_lib_dir/$imgmod_lib_name

# Create Xspress symbolic links for names needed for Odin runtime
ln -s $xspress_lib $xspress_lib_dir/libxspress3.so.1.0 2>/dev/null
ln -s $imgmod_lib $xspress_lib_dir/libimg_mod.so.1.0 2>/dev/null


# ============================================================
# Odin data
# ============================================================

# Still available for other components that need the paths
odin_data_name="odin-data"
odin_data_dir=$root_dir/$odin_data_name
odin_data_cpp_dir=$odin_data_dir/cpp
odin_data_py_dir=$odin_data_dir/python

if [[ $build_odin_data == true ]]
then

    echo -e "${CYAN}BUILDING ODIN DATA${NOCOL}"

    if [[ $build_in_place == false ]]
    then
    # Make sure directory is clean
    cd $root_dir
    rm -rf $odin_data_dir

    git clone https://github.com/odin-detector/odin-data.git $odin_data_name

    # Build and install Odin data
    cd $odin_data_dir
    # Checkout specific commit as December 2024 changes break compatibility with Xspress detector
    git checkout b157ac3ecf775522db316263eda07c2bdb46c5d2
    fi

    cd $odin_data_cpp_dir
    rm -rf build
    mkdir build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=$prefix_dir ..
    make -j 16 VERBOSE=1
    make install

    echo -e "${GREEN}ODIN DATA COMPLETE${NOCOL}\n"

fi

# ============================================================
# Xspress detector
# ============================================================

# Still available for other components that need the paths
xspress_det_name="xspress-detector"
xspress_det_dir=$root_dir/$xspress_det_name
xspress_det_cpp_dir=$xspress_det_dir/cpp
xspress_det_py_dir=$xspress_det_dir/python

if [[ $build_xspress_detector == true ]]
then

    echo -e "${CYAN}BUILDING ODIN XSPRESS DETECTOR${NOCOL}"

    if [[ $build_in_place == false ]]
    then
        # Make sure directory is clean
        cd $root_dir
        rm -rf $xspress_det_dir

        git clone https://github.com/Quantum-Detectors/xspress-detector.git $xspress_det_dir

        # Get release using git
        # NOTE: this is because git describe is used to set version macros which determine
        # the version Odin reported by the C++ controller - which is missing if we use
        # wget.
        cd $xspress_det_dir
        git checkout 0.5.0+qd0.2
    fi

    # Build and install Xspress detector
    cd $xspress_det_cpp_dir
    rm -rf build
    mkdir build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=$prefix_dir -DODINDATA_ROOT_DIR=$prefix_dir -DLIBXSPRESS_INCLUDE_DIR=$xspress_inc_dir -DLIBXSPRESS_LIBRARY=$xspress_lib -DIMGMOD_LIBRARY=$imgmod_lib ..
    make -j 16 VERBOSE=1
    make install

    echo -e "${GREEN}ODIN XSPRESS DETECTOR COMPLETE${NOCOL}\n"

fi


# ============================================================
# Diamond HDF5 filters
# ============================================================
#
# These aren't used for runtime but provide the compression filters
# used by Odin to compress the data before saving it.
#
# This allows us to read compressed files as well as decompress them
# to be more generally readable by other software.
#
# To use these filters we need to set the environment variable for
# HDF5 libraries to find them (based on where we install them):
#
# - export HDF5_PLUGIN_PATH=/odin/prefix/h5plugin
#
# Example usage to decompress dataset 'data':
#
# - h5repack -f data:NONE compressed.h5 bloated.h5
#

# Still available for other components that need the paths
hdf5_filters="hdf5filters"
hdf5_filters_dir=$root_dir/$hdf5_filters

if [[ $build_hdf5_filters == true ]]
then

    echo -e "${CYAN}BUILDING DIAMOND HDF5 FILTERS${NOCOL}"

    hdf5_filters_tar=$hdf5_filters.tar.gz

    # Make sure directory is clean
    cd $root_dir
    rm -rf $hdf5_filters_dir
    rm -f $hdf5_filters_tar

    # Get release
    wget https://github.com/DiamondLightSource/hdf5filters/archive/refs/tags/0-6-1.tar.gz -O $hdf5_filters_tar

    # Extract
    mkdir $hdf5_filters_dir
    tar -xzf $hdf5_filters_tar -C $hdf5_filters_dir --strip-components=1
    rm -f $hdf5_filters_tar

    # Build and install HDF5 filters
    cd $hdf5_filters_dir
    mkdir cmake-build && cd cmake-build
    cmake -DCMAKE_INSTALL_PREFIX=$prefix_dir -DCMAKE_BUILD_TYPE=RELEASE -DUSE_AVX2=ON ..
    make
    make install

    echo -e "${GREEN}DIAMOND HDF5 FILTERS COMPLETE${NOCOL}\n"

fi


# ============================================================
# Config Python environment
# ============================================================
#
# This creates a virtual environment for the following components:
# - config-generate
# - acquisition scripts


if [[ $build_config_env == true ]]
then
    py_conf_venv="$root_dir/config/conf_venv"
    conf_wheel="$root_dir/config/dist"
    echo -e "${CYAN}BUILDING ODIN PYTHON ENVIRONMENT${NOCOL}"

    # Clean current virtual environment
    rm -rf $py_conf_venv

    # Create environment
    python3.11 -m venv $py_conf_venv
    source $py_conf_venv/bin/activate
    pip install --upgrade pip

    # Install pyxspress
    pip install $conf_wheel/*.whl

    if ! grep -q 'export PATH=.*'"$py_conf_venv/bin" ~/.bashrc; then
        echo "export PATH=\"\$PATH:$py_conf_venv/bin\"" >> ~/.bashrc
    else
        echo "$py_conf_venv/bin is already in PATH"
    fi
    deactivate
    source ~/.bashrc

    echo -e "${GREEN}PYTHON CONFIG ENVIRONMENT COMPLETE${NOCOL}\n"
fi



# ============================================================
# Python environment
# ============================================================
#
# This creates a virtual environment for the following components:
# - Odin control
# - Odin data (Python part)
# - Xspress control
#

# Still available for other components that need the paths
py_venv=$root_dir/python

if [[ $build_python_env == true ]]
then

    echo -e "${CYAN}BUILDING ODIN PYTHON ENVIRONMENT${NOCOL}"

    # Clean current virtual environment
    rm -rf $py_venv

    # Create environment
    python3.11 -m venv $py_venv
    source $py_venv/bin/activate
    pip install --upgrade pip

    # Install dependencies
    pip install "odin-control @ git+https://git@github.com/odin-detector/odin-control.git@1.6.0"
    pip install $odin_data_py_dir
    pip install $xspress_det_py_dir
    pip install "odinprocservcontrol @ git+https://git@github.com/DiamondLightSource/odinprocservcontrol.git@c37d08552b012efc3acacfeb892ba8e292467a6f"

    deactivate

    echo -e "${GREEN}PYTHON ENVIRONMENT COMPLETE${NOCOL}\n"

fi
