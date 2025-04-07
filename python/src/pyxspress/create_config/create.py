import argparse
import math
import os
import subprocess
from pathlib import Path
from pyxspress.create_config.modules.create_expanded_substitutions import xspress_expanded_substitutions
from pyxspress.create_config.modules.create_frame_processors import frame_processor, frame_processor_json
from pyxspress.create_config.modules.create_frame_receivers import frame_reciever, frame_reciever_json
from pyxspress.create_config.modules.create_launch_yaml import yaml, launch_n_chan
from pyxspress.create_config.modules.create_meta_liveView import live_view_file, meta_writer_file
from pyxspress.create_config.modules.create_proc_serv_ioc import proc_serv_ioc
from pyxspress.create_config.modules.create_server_config import odin_server_config
from pyxspress.create_config.modules.create_folder import create_config_folder


class ConfigGenerator:
    def __init__(self, num_cards, num_chans, mark, template_dir, common_dir, target_dir):
        self.num_cards = num_cards
        self.num_chans = num_chans
        self.mark = mark
        self.template_dir = template_dir
        self.common_dir = common_dir
        self.target_dir = target_dir

    def run(self):
        funcs_full = [
            odin_server_config,
            meta_writer_file,
            launch_n_chan,
        ]
        funcs_some = [ 
            live_view_file,
            proc_serv_ioc,
            yaml,
            frame_processor,
            frame_processor_json,
            frame_reciever,
            frame_reciever_json,
        ]
        for func in funcs_full:
            func(self.num_cards, self.num_chans, self.template_dir, self.target_dir)
        for func in funcs_some:
            func(self.num_cards, self.template_dir, self.target_dir)
        xspress_expanded_substitutions(self.num_cards, self.num_chans, self.template_dir)

    def folder(self):
        create_config_folder(self.common_dir, self.target_dir)
        


def main():
    module_dir = os.path.dirname(os.path.abspath(__file__))
    parser = argparse.ArgumentParser(description="Provide arguments for the number of channels & cards")
    parser.add_argument("-c", "--channels", type=int, default=8, help="The number of channels the system is")
    parser.add_argument("-m", "--mark", type=int, default=2, help="Mark of the system, Mk1 or Mk2")
    parser.add_argument("-d", "--dir", type=str, default='/odin/config', help="Directory where the file will be generated to")

    args = parser.parse_args()
    if args.dir == "/odin/config" and not os.path.isdir("/odin/config"):
        target_dir = f"{module_dir}/config"
        print("/odin/config/ directory doesn't exist, have you run the required previous steps?")
        return
    else:
        target_dir = args.dir
    generator = ConfigGenerator(
        num_cards=math.ceil(int(args.channels)/2),
        num_chans=args.channels,
        mark=args.mark,
        template_dir=Path(module_dir +  "/templates"),
        common_dir=Path(module_dir + "/common"),
        target_dir=Path(target_dir),

    )
    generator.run()
    generator.folder()
    subprocess.run(["chmod +x ./*.sh"], cwd=target_dir, check=True, shell=True)


if __name__ == "__main__":
    main()