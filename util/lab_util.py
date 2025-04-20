import pandas as pd

from pathlib import Path
from pandas import DataFrame
from typing import List
from enum import Enum

# plot colors
light_sea_green = "#038880"
bittersweet = "#FF6C8C"
black = "#000000"
taupe_gray = "#A7A7A7"
electric_blue = "#00AAFF"


class TimeStepUnits(Enum):
    s = 1
    ms = 1e-3
    us = 1e-6
    ns = 1e-9
    ps = 1e-12


def _channel_data(data: DataFrame, num_channels: int) -> List[List[float]]:
    """
    Extract channel data from scope data.
    """
    channel_data = [[] for _ in range(0, num_channels)]
    if num_channels > 4 or num_channels < 1:
        raise ValueError(f"Number of channels {num_channels} must be in [1,4]")
    for channel in range(0, num_channels):
        channel_data[channel] = [
            float(value) for value in data[f"CH{channel+1}"].tolist()[1::]
        ]
    return channel_data


class LabData:
    def __init__(
        self,
        channel_data: DataFrame,
        time: List,
        time_step: float,
        units: TimeStepUnits,
    ):
        self.channel_data = channel_data
        self.time = time
        self.time_step = time_step
        self.units = units


def import_scope_data(file: Path, num_channels: int, units: TimeStepUnits) -> LabData:
    """
    Import scope data.
    """
    data = pd.read_csv(_get_project_root().joinpath(file))
    channel_data = _channel_data(data=data, num_channels=num_channels)
    raw_time_step = float(data["Increment"][0])

    time_step = raw_time_step / units.value
    time = [time_step * index for index, _ in enumerate(channel_data[0])]

    lab_data = LabData(
        channel_data=channel_data, time=time, time_step=time_step, units=units
    )

    return lab_data


def truncate_scope_data(
    data: LabData, start: float, end: float | None, phase_shift: float
) -> LabData:
    """
    Truncate original scope data.
    """
    start_index = int(start / data.time_step)
    if end is None:
        end_index = -1
    else:
        end_index = int(end / data.time_step)

    for index, _ in enumerate(data.channel_data):
        data.channel_data[index] = data.channel_data[index][start_index:end_index]
    data.time = [
        time_indice + phase_shift for time_indice in data.time[start_index:end_index]
    ]

    return data


def _get_project_root() -> Path:
    """
    Return the root of the project based on an anchor file.
    """
    ANCHOR_FILE = ".gitignore"
    current_path = Path(__file__)
    while current_path != current_path.parent:
        if (current_path.joinpath(ANCHOR_FILE)).exists():
            return current_path
        current_path = current_path.parent
    raise FileNotFoundError(f"Unable to find anchor file {ANCHOR_FILE}")
