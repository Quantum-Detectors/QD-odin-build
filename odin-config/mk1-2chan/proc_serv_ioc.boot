epicsEnvSet "EPICS_CA_MAX_ARRAY_BYTES", '7000000'
epicsEnvSet "EPICS_TS_MIN_WEST", '0'

epicsEnvSet "PROCSERVCONTROL", "/odin/epics/support/procServControl"

# Device initialisation
# ---------------------

dbLoadDatabase "${PROCSERVCONTROL}/iocs/autoProcServControl/dbd/autoProcServControl.dbd"

autoProcServControl_registerRecordDeviceDriver(pdbbase)

# Odin ports
drvAsynIPPortConfigure("OdinServerPort", "localhost:4001", 100, 0, 0)
drvAsynIPPortConfigure("OdinFR1Port", "localhost:4002", 100, 0, 0)
drvAsynIPPortConfigure("OdinFP1Port", "localhost:4003", 100, 0, 0)
drvAsynIPPortConfigure("OdinFR2Port", "localhost:4004", 100, 0, 0)
drvAsynIPPortConfigure("OdinFP2Port", "localhost:4005", 100, 0, 0)
drvAsynIPPortConfigure("OdinMetaPort", "localhost:4006", 100, 0, 0)
drvAsynIPPortConfigure("ControlServerPort", "localhost:4007", 100, 0, 0)
drvAsynIPPortConfigure("OdinLVPort", "localhost:4008", 100, 0, 0)
drvAsynIPPortConfigure("ADOdinPort", "localhost:4009", 100, 0, 0)

# Final ioc initialisation
# ------------------------

# PVs for control
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-01, PORT=OdinServerPort"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-02, PORT=OdinFR1Port"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-03, PORT=OdinFP1Port"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-04, PORT=OdinFR2Port"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-05, PORT=OdinFP2Port"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-06, PORT=OdinMetaPort"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-07, PORT=ControlServerPort"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-08, PORT=OdinLVPort"
dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSPRESS, PORT=ADOdinPort"

seq(procServControl, "P=XSP-ODN-01")
seq(procServControl, "P=XSP-ODN-02")
seq(procServControl, "P=XSP-ODN-03")
seq(procServControl, "P=XSP-ODN-04")
seq(procServControl, "P=XSP-ODN-05")
seq(procServControl, "P=XSP-ODN-06")
seq(procServControl, "P=XSP-ODN-07")
seq(procServControl, "P=XSP-ODN-08")
seq(procServControl, "P=XSPRESS")

iocInit

# Post-IOC init
# -------------

dbpf "XSP-ODN-01:IOCNAME" "Odin server"
dbpf "XSP-ODN-02:IOCNAME" "Odin frame receiver 1"
dbpf "XSP-ODN-03:IOCNAME" "Odin frame processor 1"
dbpf "XSP-ODN-04:IOCNAME" "Odin frame receiver 2"
dbpf "XSP-ODN-05:IOCNAME" "Odin frame processor 2"
dbpf "XSP-ODN-06:IOCNAME" "Odin meta writer"
dbpf "XSP-ODN-07:IOCNAME" "Odin control server"
dbpf "XSP-ODN-08:IOCNAME" "Odin live view"
dbpf "XSPRESS:IOCNAME" "Xspress ADOdin"
