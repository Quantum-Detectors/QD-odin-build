
def _odin_ports(num_cards):
    odin_ports_string = 'drvAsynIPPortConfigure("OdinServerPort", "localhost:4001", 100, 0, 0)\n'
    for i in range(num_cards):
        odin_ports_string += f'drvAsynIPPortConfigure("OdinFR{i+1}Port", "localhost:40{(i*2)+2:02d}", 100, 0, 0)\n'
        odin_ports_string += f'drvAsynIPPortConfigure("OdinFP{i+1}Port", "localhost:40{(i*2)+3:02d}", 100, 0, 0)\n'
        max = (i*2)+3
    odin_ports_string += f'drvAsynIPPortConfigure("OdinMetaPort", "localhost:40{max+1:02d}", 100, 0, 0)\n'
    odin_ports_string += f'drvAsynIPPortConfigure("ControlServerPort", "localhost:40{max+2:02d}", 100, 0, 0)\n'
    odin_ports_string += f'drvAsynIPPortConfigure("OdinLVPort", "localhost:40{max+3:02d}", 100, 0, 0)\n'
    odin_ports_string += f'drvAsynIPPortConfigure("ADOdinPort", "localhost:40{max+4:02d}", 100, 0, 0)'

    return odin_ports_string


def _db_load_records(num_cards):
    load_records_string = 'dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSP-ODN-01, PORT=OdinServerPort"\n'
    for i in range(num_cards):
        load_records_string += f'dbLoadRecords "${{PROCSERVCONTROL}}/db/procServControl.template", "P=XSP-ODN-{(i*2)+2:02d}, PORT=OdinFR{i+1}Port"\n'
        load_records_string += f'dbLoadRecords "${{PROCSERVCONTROL}}/db/procServControl.template", "P=XSP-ODN-{(i*2)+3:02d}, PORT=OdinFP{i+1}Port"\n'
        max = (i*2)+3
    load_records_string += f'dbLoadRecords "${{PROCSERVCONTROL}}/db/procServControl.template", "P=XSP-ODN-{max+1:02d}, PORT=OdinMetaPort"\n'
    load_records_string += f'dbLoadRecords "${{PROCSERVCONTROL}}/db/procServControl.template", "P=XSP-ODN-{max+2:02d}, PORT=ControlServerPort"\n'
    load_records_string += f'dbLoadRecords "${{PROCSERVCONTROL}}/db/procServControl.template", "P=XSP-ODN-{max+3:02d}, PORT=OdinLVPort"\n'
    load_records_string += 'dbLoadRecords "${PROCSERVCONTROL}/db/procServControl.template", "P=XSPRESS, PORT=ADOdinPort"'

    return load_records_string


def _proc_serv_control(num_cards):
    total_records = 4 + (2 * num_cards)
    proc_serv_string = ""
    for i in range(total_records):
        proc_serv_string += f'seq(procServControl, "P=XSP-ODN-{i+1:02d}")\n'

    return proc_serv_string.strip("\n")


def _post_IOC(num_cards):
    post_IOC_string = 'dbpf "XSP-ODN-01:IOCNAME" "Odin server"\n'
    for i in range(num_cards):
        post_IOC_string += f'dbpf "XSP-ODN-{(i*2)+2:02d}:IOCNAME" "Odin frame receiver {i+1}"\n'
        post_IOC_string += f'dbpf "XSP-ODN-{(i*2)+3:02d}:IOCNAME" "Odin frame processor {i+1}"\n'
        max = (i*2)+3
    post_IOC_string += f'dbpf "XSP-ODN-{max+1:02d}:IOCNAME" "Odin meta writer"\n'
    post_IOC_string += f'dbpf "XSP-ODN-{max+2:02d}:IOCNAME" "Odin control server"\n'
    post_IOC_string += f'dbpf "XSP-ODN-{max+3:02d}:IOCNAME" "Odin live view"\n'
    post_IOC_string += f'dbpf "XSPRESS:IOCNAME" "Xspress ADOdin"'

    return post_IOC_string


def proc_serv_ioc(num_cards, template_dir, files_dir):
    odin_ports_str = _odin_ports(num_cards)
    db_load_str = _db_load_records(num_cards)
    proc_serv_str = _proc_serv_control(num_cards)
    post_ioc_str = _post_IOC(num_cards)

    with open(template_dir/"proc_serv_ioc.boot.template", 'r') as proc_serv_temp:
        proc_serv_file_string = proc_serv_temp.read()
        proc_serv_file_string = proc_serv_file_string.replace("{odin_ports}", odin_ports_str)
        proc_serv_file_string = proc_serv_file_string.replace("{db_load_records}", db_load_str)
        proc_serv_file_string = proc_serv_file_string.replace("{proc_serv_control}", proc_serv_str)
        proc_serv_file_string = proc_serv_file_string.replace("{post_IOC}", post_ioc_str)

    with open(files_dir/"proc_serv_ioc.boot", 'w') as proc_serv_file:
        proc_serv_file.write(proc_serv_file_string)