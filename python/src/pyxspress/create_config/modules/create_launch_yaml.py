def _odin_processes(num_cards):
    odin_process_string = "procServ -P 4001 /odin/config/stOdinServer.sh\n"
    odin_process_string += "procServ -P 4002 /odin/config/stMetaWriter.sh\n"
    odin_process_string += "procServ -P 4003 /odin/config/stControlServer.sh\n"
    odin_process_string += "procServ -P 4004 /odin/config/stLiveViewMerge.sh\n\n"
    odin_process_string += (
        "# ADOdin\nprocServ -P 4005 /odin/config/stXspressADOdin.sh\n\n"
    )
    base_port = 4010
    odin_process_string += "# Frame Reciever and Process pairs\n"
    for i in range(num_cards):
        odin_process_string += (
            f"procServ -P {base_port + (i*2)} /odin/config/stFrameReceiver{i+1}.sh\n"
        )
        odin_process_string += (
            f"procServ -P {base_port + (i*2)+1} /odin/config/stFrameProcessor{i+1}.sh\n"
        )
    return odin_process_string


def launch_n_chan(num_cards, num_chans, template_dir, files_dir):
    odin_processes_str = _odin_processes(num_cards)
    with open(template_dir / "launch_nchan_odin.sh.template", "r") as launch_temp:
        launch_file_string = launch_temp.read()
        launch_file_string = launch_file_string.replace("{chans}", str(num_chans))
        launch_file_string = launch_file_string.replace(
            "{odin_processes}", odin_processes_str
        )
    with open(files_dir / f"launch_{num_chans}chan_odin.sh", "w") as launch_file:
        launch_file.write(launch_file_string)


def yaml(num_cards, template_dir, files_dir):
    processes = (num_cards * 2) + 4
    with open(template_dir / "odin_proc_serv_ioc.yaml.template", "r") as yaml_temp:
        yaml_string = yaml_temp.read()
        yaml_string = yaml_string.replace("{processes}", str(processes))
    with open(files_dir / "odin_proc_serv_ioc.yaml", "w") as yaml_file:
        yaml_file.write(yaml_string)
