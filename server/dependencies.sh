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

# Install Log4cxx manually as we have no log4cxx-devel package in CentOS Stream 9
tmp_log4cxx_dir=/tmp/log4cxx
mkdir -p $tmp_log4cxx_dir
cd $tmp_log4cxx_dir
sudo yum -y install wget apr-devel apr-util-devel
wget https://dlcdn.apache.org/logging/log4cxx/1.2.0/apache-log4cxx-1.2.0.tar.gz
tar -xvzf apache-log4cxx-1.2.0.tar.gz
cd $tmp_log4cxx_dir/apache-log4cxx-1.2.0
mkdir build
cd $tmp_log4cxx_dir/apache-log4cxx-1.2.0/build
cmake .. && make -j 8 && sudo make install
rm -rf $tmp_log4cxx_dir

# EPICS dependencies
sudo yum -y install perl rpcgen libtirpc-devel re2c libX11-devel libXtst-devel libxml2-devel libXt-devel libXmu-devel motif-devel giflib-devel

# EDM fonts including substitutions for arial
sudo yum install xorg-x11-fonts* liberation-fonts

# procServ
sudo yum -y install procServ telnet

# Other tools
sudo yum -y install procps
