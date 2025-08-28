#!/usr/bin/bash

# ============================================================
# Server depencencies
# ============================================================

# Update and configure the repositories
sudo yum -y update
sudo yum -y install epel-release

# Python 3.11
sudo yum -y install python3.11 python3.11-pip python3.11-devel
pip3.11 install --upgrade pip
pip3.11 install pipenv

# Essential build tools
sudo yum -y groupinstall 'Development Tools'

# Additional packages
sudo dnf config-manager --set-enabled crb

# Install C++ tools and libraries
sudo yum -y install cmake
sudo yum -y install blosc-devel boost-devel zeromq-devel libpcap-devel hdf5-devel

# Install Log4cxx (now available on CentOS Stream 9)
sudo yum -y install log4cxx-devel

# EPICS dependencies
sudo yum -y install perl rpcgen libtirpc-devel re2c libX11-devel libXtst-devel libxml2-devel libXt-devel libXmu-devel motif-devel giflib-devel

# EDM fonts including substitutions for arial
sudo yum -y install xorg-x11-fonts* liberation-fonts liberation-narrow-fonts

# procServ
sudo yum -y install procServ telnet

# Other tools
sudo yum -y install procps numactl

# Cursor for pyxspress GUI
sudo yum -y install libxcb xcb-util*
