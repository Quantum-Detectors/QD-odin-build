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
# Directory setup
# ============================================================

# Root and install directories
root_dir=/odin
prefix_dir=$root_dir/prefix

echo -e "${RED}TARGET DIR: $prefix_dir${NOCOL}"

# Make sure target is clean
rm -rf $prefix_dir

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
ln -s $xspress_lib $xspress_lib_dir/libxspress3.so.1.0
ln -s $imgmod_lib $xspress_lib_dir/libimg_mod.so.1.0

# ============================================================
# Odin data
# ============================================================

echo -e "${CYAN}BUILDING ODIN DATA${NOCOL}"

# Make sure checkout directory is clean
cd $root_dir
odin_data_name="odin-data"
odin_data_cpp_dir=$root_dir/$odin_data_name/cpp
odin_data_py_dir=$root_dir/$odin_data_name/python
rm -rf $root_dir/$odin_data_name

git clone https://github.com/odin-detector/odin-data.git $odin_data_name

# Build and install Odin data
cd $odin_data_cpp_dir
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix_dir ..
make -j 16 VERBOSE=1
make install

echo -e "${GREEN}ODIN DATA COMPLETE${NOCOL}\n"


# ============================================================
# Xspress detector
# ============================================================

echo -e "${CYAN}BUILDING ODIN XSPRESS DETECTOR${NOCOL}"

# Make sure checkout directory is clean
cd $root_dir
xspress_det_name="xspress-detector"
xspress_det_cpp_dir=$root_dir/$xspress_det_name/cpp
xspress_det_py_dir=$root_dir/$xspress_det_name/python
rm -rf $root_dir/$xspress_det_name

git clone https://github.com/Quantum-Detectors/xspress-detector.git $xspress_det_name

# Build and install Xspress detector
cd $xspress_det_cpp_dir
# TODO: remove when feature/qd-build is merged into qd-main
git checkout feature/qd-build
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix_dir -DODINDATA_ROOT_DIR=$prefix_dir -DLIBXSPRESS_INCLUDE_DIR=$xspress_inc_dir -DLIBXSPRESS_LIBRARY=$xspress_lib -DIMGMOD_LIBRARY=$imgmod_lib ..
make -j 16 VERBOSE=1
make install

echo -e "${GREEN}ODIN XSPRESS DETECTOR COMPLETE${NOCOL}\n"


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

echo -e "${CYAN}BUILDING DIAMOND HDF5 FILTERS${NOCOL}"

# Make sure checkout directory is clean
cd $root_dir
hdf5_filters="hdf5filters"
hdf5_filters_dir=$root_dir/$hdf5_filters
rm -rf $hdf5_filters_dir

git clone https://github.com/DiamondLightSource/hdf5filters.git $hdf5_filters_dir

# Build and install HDF5 filters
cd $hdf5_filters_dir
mkdir cmake-build && cd cmake-build
cmake -DCMAKE_INSTALL_PREFIX=$prefix_dir -DCMAKE_BUILD_TYPE=RELEASE -DUSE_AVX2=ON ..
make
make install

echo -e "${GREEN}DIAMOND HDF5 FILTERS COMPLETE${NOCOL}\n"


# ============================================================
# Python environment
# ============================================================
#
# This creates a virtual environment for the following components:
# - Odin control
# - Odin data (Python part)
# - Xspress control
#

echo -e "${CYAN}BUILDING ODIN PYTHON ENVIRONMENT${NOCOL}"

# Virtual environment location
py_venv=$root_dir/python

# Create environment
python3.11 -m venv $py_venv
source $py_venv/bin/activate
pip install --upgrade pip

# Install dependencies
pip install "odin-control @ git+https://git@github.com/odin-detector/odin-control.git"
pip install $odin_data_py_dir
pip install $xspress_det_py_dir
pip install "odinprocservcontrol @ git+https://git@github.com/DiamondLightSource/odinprocservcontrol.git"

deactivate

echo -e "${GREEN}PYTHON ENVIRONMENT COMPLETE${NOCOL}\n"
