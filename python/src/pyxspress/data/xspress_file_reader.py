"""
Xspress file reader module

Provides a class which can read the Xspress channel data from the HDF5 file
"""

import os
from typing import List, Optional, Union

import h5py
import numpy

from pyxspress.util import Loggable


class XspressFileReader(Loggable):
    num_scalars = 9

    def __init__(self):
        super().__init__()

        self.open = False

        self.a_filename = None
        self.b_filename = None
        self.meta_filename = None

        self.a_file = None
        self.b_file = None
        self.meta_file = None

        # Information about the files
        self.num_frames = 0
        self.num_channels = 0
        self.channels = []

        self.a_channel_datasets = []
        self.b_channel_datasets = []
        self.meta_file_datasets = []

    def close_files(self):
        if self.a_file:
            self.logger.debug(f"Closing {self.a_filename}")
            self.a_file.close()
            self.b_file = None
            self.a_filename = None
        if self.b_file:
            self.logger.debug(f"Closing {self.b_filename}")
            self.b_file.close()
            self.b_file = None
            self.b_filename = None

        self.open = False

    def open_files(
        self, a_filename: str, b_filename: Optional[str], meta_filename: Optional[str]
    ) -> bool:
        """Open the files provided.

        The primary file is required but B and meta are optional.

        Args:
            a_filename (str): A filename.
            b_filename (Optional[str]): B filename (optional).
            meta_filename (Optional[str]): Meta filename (optional)

        Returns:
            bool: True if successfully opened files, otherwise False.
        """
        # Sanity check files exist
        if not os.path.isfile(a_filename):
            self.logger.error(f"Could not find file {a_filename}. Does it exist?")
            return False
        if b_filename and not os.path.isfile(b_filename):
            self.logger.error(f"Could not find file {b_filename}. Does it exist?")
            return False
        if meta_filename and not os.path.isfile(meta_filename):
            self.logger.error(f"Could not find file {meta_filename}. Does it exist?")
            return False

        self.close_files()

        try:
            self.a_file = h5py.File(a_filename)

            self.a_channel_datasets = [
                key for key in self.a_file.keys() if "mca" in key
            ]
            self.channels = [
                int(key.replace("mca_", ""))
                for key in self.a_file.keys()
                if "mca" in key
            ]

            if b_filename:
                self.b_file = h5py.File(b_filename)
                self.b_channel_datasets = [
                    key for key in self.b_file.keys() if "mca" in key
                ]
                self.channels += [
                    int(key.replace("mca_", ""))
                    for key in self.b_file.keys()
                    if "mca" in key
                ]
            else:
                self.b_channel_datasets = []

            self.num_channels = len(self.channels)

            # Work out number of frames
            self.num_frames = len(self.a_file[self.a_channel_datasets[0]])
            if self.b_channel_datasets:
                num_b_frames = len(self.b_file[self.b_channel_datasets[0]])
                if num_b_frames != self.num_frames:
                    self.logger.error(
                        f"Number of frames in file A ({self.num_frames}) "
                        f"does not match file B ({num_b_frames})"
                    )
                    return False

            if meta_filename:
                self.meta_file = h5py.File(meta_filename)
                self.meta_file_datasets = [
                    key for key in self.meta_file.keys() if "scalar" in key
                ]

            self.logger.debug(
                "Parsed files:\n"
                f" - Num channels: {self.num_channels}\n"
                f" - Num frames: {self.num_frames}\n"
                f" - Channels: {self.channels}\n"
                f" - Channel datasets:\n"
                f"    A - {self.a_channel_datasets}\n"
                f"    B - {self.b_channel_datasets}\n"
                f" - Meta datasets: {self.meta_file_datasets}"
            )

            self.a_filename = a_filename
            self.b_filename = b_filename
            self.meta_filename = meta_filename

            self.open = True

            return True

        except Exception as e:
            self.logger.error(f"Error parsing files: {e}")
            return False

    def get_channel_data(
        self, channels: Union[int, List[int]], frame: int
    ) -> numpy.ndarray:
        """Get data of a single frame for either a single channel or all channels

        This is zero-indexed (i.e. 0 is the first frame and channel)

        Args:
            channels (Union[int, List[int]]): Channel or channels or -1 for all
            frame (int): Frame number

        Returns:
            numpy.ndarray: Data array
        """
        if not self.open:
            self.logger.error(
                f"No file(s) open to get data for frame {frame}, channel {channels}"
            )

        self.logger.debug(f"Getting data for frame {frame}, channels {channels}")

        # All channels
        if channels == -1:
            data = numpy.vstack(
                ([self.a_file[ds][frame, 0, :] for ds in self.a_channel_datasets])
            )
            if len(self.b_channel_datasets) > 1:
                data = numpy.vstack(
                    (
                        data,
                        [
                            self.b_file[ds][frame, 0, :]
                            for ds in self.b_channel_datasets
                        ],
                    )
                )

            self.logger.debug(f"Got data of shape {data.shape}")
            return data

        # List of channels
        elif isinstance(channels, list):
            if len(channels) == 1:
                return self.get_channel_data(channels[0], frame)

            data = numpy.vstack(([self.get_channel_data(ch, frame) for ch in channels]))
            self.logger.debug(f"Got data of shape {data.shape}")
            return data

        # Single channel
        else:
            dataset_name = f"mca_{channels}"
            if dataset_name in self.a_channel_datasets:
                return self.a_file[dataset_name][frame, 0, :]
            elif dataset_name in self.b_channel_datasets:
                return self.b_file[dataset_name][frame, 0, :]
            else:
                self.logger.error(f"Invalid channel {channels}")
                return numpy.array([0, 0])

    def get_scalar_data(
        self, channels: Union[int, List[int]], frame: int
    ) -> Optional[numpy.ndarray]:
        """Get the scalar data for an specific frame number

        Args:
            channels (Union[int, List[int]]): Channel or channels or -1 for all
            frame (int): Frame number

        Returns:
            numpy.ndarray: Array of scalar values
        """
        if self.meta_file is None:
            # No scalar file to read from
            return None

        self.logger.debug(
            f"Getting scalar values for frame {frame} and channels {channels}"
        )
        num_scalers = 9

        if channels == -1:
            data = numpy.empty((self.num_channels, num_scalers))
            for channel in range(self.num_channels):
                data[channel, :] = self.get_scalar_data(channel, frame)

        elif isinstance(channels, list):
            if len(channels) == 1:
                return self.get_scalar_data(channels[0], frame)

            data = numpy.empty((len(channels), num_scalers))
            row_index = 0
            for channel in channels:
                data[row_index, :] = self.get_scalar_data(channel, frame)
                row_index += 1

        else:
            data = numpy.empty((self.num_scalars))
            for scalar_num in range(self.num_scalars):
                dataset_name = f"scalar_{scalar_num}"
                data[scalar_num] = self.meta_file[dataset_name][frame][channels]

        return data
