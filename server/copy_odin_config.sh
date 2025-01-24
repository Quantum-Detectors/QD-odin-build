#!/usr/bin/bash

# ============================================================
# Copy Odin runtime config
# ============================================================
#
# This copies the runtime configuration files needed for
# Odin components and ADOdin
#
# Args:
#
#   -n : number of channels (1-64)
#   -m : mark (1 or 2)
#

# Colours
CYAN="\033[0;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NOCOL="\033[0m"

# Get parent directory
script_dir="$( cd "$( dirname "$0" )" && pwd )"
root_dir="$(dirname $script_dir)"

# Parse user options
while getopts n:m:h flag
do
    case "${flag}" in
        n) num_channels=${OPTARG};;
        m) mark=${OPTARG};;
        h)
            echo ""
            echo -e "${CYAN}=======================================================${NOCOL}"
            echo "Odin configuration script"
            echo -e "${CYAN}=======================================================${NOCOL}"
            echo ""
            echo "This script copies the set of configuration files"
            echo "matching the requested number of channels and"
            echo "generation of Xspress 3X system."
            echo ""
            echo ""
            echo "Choose from the following options:"
            echo ""
            echo "    -h : Print this help message"
            echo "    -n : Number of channels"
            echo "    -m : Mark (1 or 2)"
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

# Defaults
if [[ -z $num_channels ]]
then
    num_channels=8;
fi

if [[ -z $mark ]]
then
    mark=1;
fi

# Validate args
if [[ $mark -ge 3 ]] || [[ $mark -le 0 ]]
then
    echo "Mark should be one or two. Selected: $mark"
    exit 1
fi

if [[ $num_channels -ge 64 ]] || [[ $num_channels -le 0 ]]
then
    echo "Number of channels should be 1-64. Got: $num_channels"
    exit 2
fi

echo -e ""
echo -e "${CYAN}=======================================================${NOCOL}"
echo "Selected parameters"
echo -e "${CYAN}=======================================================${NOCOL}"

echo -e " - Number of channels: ${GREEN}$num_channels${NOCOL}"
echo -e " - Mark: ${GREEN}$mark${NOCOL}"
echo -e ""
echo -e "${CYAN}=======================================================${NOCOL}"
echo -e ""

config_dir="mk${mark}-${num_channels}chan"
echo -e "Config dir: ${CYAN}$config_dir${NOCOL}"
echo ""

# Check the configuration exists for combination of channels and mark
full_dir="$root_dir/odin-config/$config_dir"
if [[ ! -d $full_dir ]]
then
    echo -e "${RED}[ERROR]${NOCOL} Directory $full_dir does not exist for this combination of settings."
    exit 3
fi

# Copy the matching Odin configuration
target_dir="/odin/config"
echo -e "${GREEN}[INFO]${NOCOL} Copying Odin config to $target_dir"

if [[ ! -d $target_dir ]]
then
    echo -e "${GREEN}[INFO]${NOCOL} Creating config directory"
    mkdir -p $target_dir
else
    echo -e "${YELLOW}[WARN]${NOCOL} Overwriting existing config"
    rm -f $target_dir/*
fi

cp -r $full_dir/* /odin/config

# Copy the ADOdin IOC template

# Get the correct source template
db_sub_source_filename=xspress_expanded_${num_channels}ch.substitutions
source_adodin_db_file="$root_dir/adodin-config/$db_sub_source_filename"

# Copy to EPICS config directory and also ADOdin if it exists
db_sub_target_filename=xspress_expanded.substitutions
db_sub_target_config_dir=/odin/epics/config/$db_sub_target_filename

# Always copy to config directory
echo -e "${GREEN}[INFO]${NOCOL} Copying ADOdin config to $db_sub_target_config_dir"
cp $source_adodin_db_file $db_sub_target_config_dir

# Check if we can also copy to ADOdin (if it exists)
adodin_dir=/odin/epics/support/ADOdin
if [[ -d $adodin_dir ]]
then
    db_sub_target_adodin_dir=$adodin_dir/iocs/xspress/xspressApp/Db/$db_sub_target_filename

    echo -e "${GREEN}[INFO]${NOCOL} Copying ADOdin config to $db_sub_target_adodin_dir"
    cp $source_adodin_db_file $db_sub_target_adodin_dir

    # Remake ADOdin to expand substitutions db file
    echo -e "${GREEN}[INFO]${NOCOL} Rebuilding ADOdin"
    cd $adodin_dir
    make > /dev/null
    cd - > /dev/null
fi

# Copy any common files
echo -e "${GREEN}[INFO]${NOCOL} Copying common configuration files"
common_dir="$root_dir/odin-config/common"
cp -r $common_dir/* /odin/config

echo ""
echo -e "${GREEN}Copying complete${NOCOL}"
echo ""
exit 0
