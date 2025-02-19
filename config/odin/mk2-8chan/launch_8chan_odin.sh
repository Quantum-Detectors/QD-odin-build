#!/usr/bin/bash

# ============================================================
# Launch 8 channel Odin processes
# ============================================================

BASE_PORT=4001
PROC_SERV_BASE_PORT=9001

# Launch from config folder
cd /odin/config

# Odin processes
procServ -P `expr $BASE_PORT + 0` /odin/config/stOdinServer.sh
procServ -P `expr $BASE_PORT + 1` /odin/config/stFrameReceiver1.sh
procServ -P `expr $BASE_PORT + 2` /odin/config/stFrameProcessor1.sh
procServ -P `expr $BASE_PORT + 3` /odin/config/stFrameReceiver2.sh
procServ -P `expr $BASE_PORT + 4` /odin/config/stFrameProcessor2.sh
procServ -P `expr $BASE_PORT + 5` /odin/config/stMetaWriter.sh
procServ -P `expr $BASE_PORT + 6` /odin/config/stControlServer.sh
procServ -P `expr $BASE_PORT + 7` /odin/config/stLiveViewMerge.sh
procServ -P `expr $BASE_PORT + 9` /odin/config/stFrameReceiver3.sh
procServ -P `expr $BASE_PORT + 10` /odin/config/stFrameProcessor3.sh
procServ -P `expr $BASE_PORT + 11` /odin/config/stFrameReceiver4.sh
procServ -P `expr $BASE_PORT + 12` /odin/config/stFrameProcessor4.sh

# ADOdin
procServ -P `expr $BASE_PORT + 8` /odin/config/stXspressADOdin.sh

# ProcServControl IOCs
procServ -P `expr $PROC_SERV_BASE_PORT + 0` /odin/config/stProcServControl.sh
procServ -P `expr $PROC_SERV_BASE_PORT + 1` /odin/config/stOdinProcServControl.sh

cd -
