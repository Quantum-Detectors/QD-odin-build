import os
from pathlib import Path
process_names = [
    "OdinServer",
    "FrameReceiver",
    "FrameProcessor",
    "MetaWriter",
    "ControlServer",
    "LiveViewMerge"]
prefix = "XSP-ODN-"


def make_process_dicts(num_cards):
    processes = []
    processes.append({
        "Name": process_names[0],
        "Process": f"{prefix}01",
    })
    for i in range(num_cards):
        processes.append({
            "Name": f"{process_names[1]}{i+1}",
            "Process": f"{prefix}{(i+1)*2:02d}"
        })
        processes.append({
            "Name": f"{process_names[2]}{i+1}",
            "Process": f"{prefix}{((i+1)*2)+1:02d}"
        })
    index = (2 * num_cards) + 1
    for j in range(3, len(process_names)):
        processes.append({
            "Name": process_names[j],
            "Process": f"{prefix}{index+1:02d}",
        })
        index += 1
    processes.append({
        "Name": "XSPRESS",
        "Process": "XSPRESS"
    })
    return processes


def buttons(processes, template_dir):
    full_process_string = ""
    with open(template_dir/"gui_button.template", 'r') as button_file_temp:
        button_string = button_file_temp.read()
    ypos = 40
    full_process_string += solo_button(button_string, processes[0], 225, ypos)
    for process in processes[1:-1]:
        if (int(process["Process"].split("-")[2]) % 2):
            # Left align odd buttons
            xpos = 225
        else:
            # Right align even buttons
            xpos = 395
        ypos += 35
        full_process_string += solo_button(button_string, process, xpos, ypos)
    full_process_string += solo_button(button_string, processes[-1], 395, 40)
    return full_process_string


def solo_button(button_string, process, xpos, ypos):
    process_string = button_string.replace("{proc_serv}", process["Process"]) 
    process_string = process_string.replace("{name}", process["Name"])
    process_string = process_string.replace("{xpos1}", f"{xpos}")
    process_string = process_string.replace("{xpos2}", f"{xpos + 4}")
    process_string = process_string.replace("{ypos1}", f"{ypos}")
    process_string = process_string.replace("{ypos2}", f"{ypos + 2}")
    return process_string


def main_gui(full_process_string, num_cards, template_dir):
    height = 210 + (num_cards * 35)
    button_pos = height - 65
    exit_button_pos = height - 30
    edl_dir = Path("/odin/epics/support/ADOdin/iocs/xspress/xspresApp/opl/edl")
    with open(template_dir/"gui_proc_serv.edl.template", 'r') as proc_file_temp:
        proc_file_string = proc_file_temp.read()
    proc_file_string = proc_file_string.replace("{processes}", full_process_string)
    proc_file_string = proc_file_string.replace("{screen_height}", str(height))
    proc_file_string = proc_file_string.replace("{y_pos_buttons}", str(button_pos))
    proc_file_string = proc_file_string.replace("{y_pos_exit}", str(exit_button_pos))
    if edl_dir.exists() and edl_dir.is_dir(): 
        with open(edl_dir/"ODNProcServ.edl", "w") as edl_file:
            edl_file.write(proc_file_string)
    else:
        print("Not the expected gui structure, not generating gui file")


def create_gui(num_cards, template_dir):
    # num_cards = 4
    # template_dir = Path("C:\\source\\repos\\qd-odin-build\\python\\src\\pyxspress\\create_config\\templates")
    processes = make_process_dicts(num_cards)
    full_process_string = buttons(processes, template_dir)
    main_gui(full_process_string, num_cards, template_dir)


if __name__ == "__main__":
    create_gui()
