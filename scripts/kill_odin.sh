pkill -e -2 -f procServ

pkill -e -9 -f frameProcessor
pkill -e -9 -f frameReceiver
pkill -e -9 -f xspress_control
pkill -e -9 -f xspress_meta_writer
pkill -e -9 -f xspress_live_merge
pkill -e -9 -f xspressControl

pkill -e -9 'stFrameProcessor*'
pkill -e -9 'stFrameReceiver*'
pkill -e -9 -f stLiveViewMerge.sh
pkill -e -9 -f stOdinServer.sh
pkill -e -9 -f stMetaWriter.sh
