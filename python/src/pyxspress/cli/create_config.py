"""
Create the Odin Xspress runtime configuration

This is used to generate all of the files needed to run Odin based on the
connected Xspress system.

This includes:

- Odin server configuration files
- Launch scripts for Odin and EPICS processes

"""

import math
import os
from pathlib import Path

import click

from pyxspress.create_config.config_generator import ConfigGenerator
from pyxspress.util import setup_basic_logging


@click.command(
    help="Generate the Odin runtime configuration for an Xspress system",
    context_settings={"show_default": True, "help_option_names": ["-h", "--help"]},
)
@click.option(
    "-c",
    "--channels",
    type=int,
    default=8,
    help="Number of channels in the system",
)
@click.option(
    "-m",
    "--mark",
    type=int,
    default=2,
    help="Generation of Xspress 3X system (Mk1 or Mk2)",
)
@click.option(
    "-od",
    "--odin_dir",
    type=str,
    default="/odin/config",
    help="Where to write generated Odin configuration files",
)
@click.option(
    "-ed",
    "--epics_dir",
    type=str,
    default="/odin/epics/config",
    help="Where to write generated EPICS configuration files",
)
@click.option(
    "-t",
    "--test",
    is_flag=True,
    default=False,
    help="Used for developer testing (creates files in place)",
)
def main(channels: int, mark: int, odin_dir: str, epics_dir: str, test: bool) -> None:
    logger = setup_basic_logging()

    if test:
        # Change output directories
        odin_dir = f"{os.getcwd()}/config"
        epics_dir = f"{os.getcwd()}/config"

    if mark == 1:
        raise ValueError("Mark 1 not currently supported")

    logger.info(f"Odin output directory: {odin_dir}")
    logger.info(f"EPICS config directory: {epics_dir}")

    # Validate the directory paths
    if os.path.isfile(odin_dir):
        raise ValueError(f"Odin directory {odin_dir} is a file")
    if os.path.isfile(epics_dir):
        raise ValueError(f"EPICS config directory {epics_dir} is a file")

    # Create the Odin configuration directory if it doesn't exist
    if not os.path.exists(odin_dir):
        logger.info(f"Creating config directory: {odin_dir}")
        os.mkdir(odin_dir)

    # Generate configuration
    generator = ConfigGenerator(
        num_cards=math.ceil(int(channels) / 2),
        num_chans=channels,
        mark=mark,
        odin_dir=Path(odin_dir),
        epics_dir=Path(epics_dir),
        test=test,
    )
    generator.clean()
    generator.generate()


if __name__ == "__main__":
    main()
