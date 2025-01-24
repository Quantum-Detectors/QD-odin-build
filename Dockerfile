FROM quay.io/centos/centos:stream9

# This is the build location for the Odin and EPICS components
RUN mkdir /odin
RUN mkdir /odin/epics
WORKDIR /odin

# Update and configure the repositories
RUN yum -y update
RUN yum -y install epel-release

# Python 3.11
RUN yum -y install python3.11 python3.11-pip python3.11-devel
RUN pip3.11 install --upgrade pip
RUN pip3.11 install pipenv

# Essential build tools
RUN yum -y groupinstall 'Development Tools'

# Additional packages
RUN dnf config-manager --set-enabled crb

# Install C++ tools and libraries
RUN yum -y install cmake
RUN yum -y install blosc-devel boost-devel zeromq-devel libpcap-devel hdf5-devel

# Install Log4cxx manually as we have no log4cxx-devel package in CentOS Stream 9
RUN mkdir /odin/tmp
WORKDIR /odin/tmp
RUN yum -y install wget apr-devel apr-util-devel
RUN wget https://dlcdn.apache.org/logging/log4cxx/1.2.0/apache-log4cxx-1.2.0.tar.gz
RUN tar -xvzf apache-log4cxx-1.2.0.tar.gz
WORKDIR /odin/tmp/apache-log4cxx-1.2.0
RUN mkdir build
WORKDIR /odin/tmp/apache-log4cxx-1.2.0/build
RUN cmake .. && make -j 8 && make install
WORKDIR /odin
RUN rm -rf /odin/tmp

# EPICS dependencies
RUN yum -y install perl rpcgen libtirpc-devel re2c libX11-devel libXtst-devel libxml2-devel libXt-devel libXmu-devel motif-devel giflib-devel

# EDM fonts including substitutions for arial
RUN yum -y install xorg-x11-fonts* liberation-fonts

# procServ
RUN yum -y install procServ telnet

# Other tools
RUN yum -y install procps numactl

# EPICS configuration and RELEASE files
RUN mkdir /odin/epics/config
ADD epics/synapp_modules /odin/epics/config
ADD epics/RELEASE.local /odin/epics/config
ADD epics/xspress_IOC_RELEASE /odin/epics/config

# EDM configuration files
RUN mkdir /odin/epics/edm
ADD edm-config/colors.list /odin/epics/edm
ADD edm-config/fonts.list /odin/epics/edm

# Build scripts
ADD scripts/odin_build.sh /odin
ADD scripts/epics_build.sh /odin/epics

# Xspress binaries
ADD xspress /odin/xspress

# Odin configuration files
RUN mkdir /odin/config
ADD odin-config/xspress3/* /odin/config
