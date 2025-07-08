from pathlib import Path
import os
import shutil
import subprocess


def _odin_data_template(num_cards):
    od_temp_string = ""
    for i in range(num_cards):
        od_temp_string += (
            f'    {{ "XSPRESS", ":OD{i+1}:", "ODN.OD", "1", "{i}", "{num_cards}" }}\n'
        )

    return od_temp_string.strip("\n")


def _xspress_channel_template(num_chans):
    xspress_chan_temp_string = ""
    for i in range(num_chans):
        xspress_chan_temp_string += (
            '    {{ "XSPRESS", ":CAM:", "ODN.CAM", "'
            f'{i}", "{i+1}", "{num_chans}", "1" }}\n'
        )
    return xspress_chan_temp_string.strip("\n")


def _xspress_fem_template(num_cards):
    xspress_fem_string = ""
    for i in range(num_cards):
        xspress_fem_string += (
            f'    {{ "XSPRESS", ":CAM:", "ODN.CAM", "{i}", "{num_cards}", "1" }}\n'
        )
    return xspress_fem_string.strip("\n")


def _odin_procserv_template(num_cards):
    odin_procserv_string = '    { "ODN", "OdinServer", "XSP-ODN-01" }\n'
    odin_procserv_string += '    { "ODN", "MetaWriter", "XSP-ODN-02" }\n'
    odin_procserv_string += '    { "ODN", "ControlServer", "XSP-ODN-03" }\n'
    odin_procserv_string += '    { "ODN", "LiveViewMerge", "XSP-ODN-04" }\n'

    for i in range(num_cards):
        odin_procserv_string += (
            f'    {{ "ODN", "FrameReceiver{i+1}", "XSP-ODN-{((i+1)*2)+3:02d}" }}\n'
        )
        odin_procserv_string += (
            f'    {{ "ODN", "FrameProcessor{i+1}", "XSP-ODN-{((i+1)*2)+4:02d}" }}\n'
        )
    odin_procserv_string += '    { "ODN", "XSPRESS", "XSPRESS" }\n'
    return odin_procserv_string.strip("\n")


def xspress_expanded_substitutions(num_cards, num_chans, template_dir, test):
    if not test:
        files_dir = "/odin/epics/config/"
        adodin_dir = Path("/odin/epics/support/ADOdin")
    else:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        files_dir = f"{current_dir}/../support/ADOdin/expanded_substitustions/"

    odin_data_string = _odin_data_template(num_cards)
    xspress_channel_string = _xspress_channel_template(num_chans)
    xspress_fem_string = _xspress_fem_template(num_cards)
    odin_procserv_string = _odin_procserv_template(num_cards)

    with open(
        template_dir / "xspress_expanded.substitutions.template", "r"
    ) as xspress_expanded_temp:
        xspress_expanded_string = xspress_expanded_temp.read()
        xspress_expanded_string = xspress_expanded_string.replace(
            "{chans}", str(num_chans)
        )
        xspress_expanded_string = xspress_expanded_string.replace(
            "{cards}", str(num_cards)
        )
        xspress_expanded_string = xspress_expanded_string.replace(
            "{odin_data_template}", odin_data_string
        )
        xspress_expanded_string = xspress_expanded_string.replace(
            "{xspress_channel_template}", xspress_channel_string
        )
        xspress_expanded_string = xspress_expanded_string.replace(
            "{xspress_fem_template}", xspress_fem_string
        )
        xspress_expanded_string = xspress_expanded_string.replace(
            "{odin_procserv_template}", odin_procserv_string
        )

    file_path = Path(files_dir + "xspress_expanded.substitutions")
    with open(file_path, "w") as xspress_expanded_file:
        xspress_expanded_file.write(xspress_expanded_string)

    if not test:
        if adodin_dir.exists() and adodin_dir.is_dir():  # Check if folder exists
            shutil.copy(file_path, adodin_dir)  # Copy file
            try:
                subprocess.run(["make"], cwd=adodin_dir, check=True)
            except subprocess.CalledProcessError as e:
                print(f"Make command failed with error {e}")
