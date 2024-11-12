#!/usr/bin/env python3

# https://github.com/domdfcoding/PySetWacom
# https://github.com/domdfcoding/PySetWacom/tree/master/PySetWacom

from typing import NamedTuple, Sequence
from sh import xsetwacom  # type: ignore
from enum import StrEnum
from dataclasses import dataclass

# https://github.com/domdfcoding/PySetWacom/blob/master/PySetWacom/button.py
# https://github.com/domdfcoding/PySetWacom/blob/master/PySetWacom/device.py
# https://github.com/domdfcoding/PySetWacom/blob/master/PySetWacom/profile.py

# xsetwacom --list devices
# xsetwacom --list modifiers
# xsetwacom --list parameters


class DeviceType(StrEnum):
    STYLUS = "STYLUS"
    PAD = "PAD"
    TOUCH = "TOUCH"
    ERASER = "ERASER"


class ParameterNames(StrEnum):
    # have ids (len 3)
    AbsWheel2Down = "AbsWheel2Down"
    AbsWheel2Up = "AbsWheel2Up"
    AbsWheelDown = "AbsWheelDown"
    AbsWheelUp = "AbsWheelUp"
    RelWheelDown = "RelWheelDown"
    RelWheelUp = "RelWheelUp"
    StripLeftDown = "StripLeftDown"
    StripLeftUp = "StripLeftUp"
    StripRightDown = "StripRightDown"
    StripRightUp = "StripRightUp"
    Button = "Button"

    # No ids (len 2)
    Area = "Area"
    BindToSerial = "BindToSerial"
    CursorProximity = "CursorProximity"
    Gesture = "Gesture"
    Mode = "Mode"
    PanScrollThreshold = "PanScrollThreshold"
    PressureCurve = "PressureCurve"
    PressureRecalibration = "PressureRecalibration"
    RawSample = "RawSample"
    Rotate = "Rotate"
    ScrollDistance = "ScrollDistance"
    Suppress = "Suppress"
    TabletDebugLevel = "TabletDebugLevel"
    TabletPCButton = "TabletPCButton"
    TapTime = "TapTime"
    Threshold = "Threshold"
    ToolDebugLevel = "ToolDebugLevel"
    Touch = "Touch"
    ZoomDistance = "ZoomDistance"


@dataclass
class Parameter:
    name: ParameterNames
    value: str
    """
    Optional, but always in 2nd position if it's there
    """


class Button(Parameter):
    """
    Name must match one of the values from `xsetwacom --list parameters`
    """

    id: str


@dataclass
class Device:
    name: str
    id: str
    device_type: DeviceType

    def get_parameters(self) -> list[tuple[ParameterNames, str] | tuple[ParameterNames, str, str]]:
        prefix = f'xsetwacom set "{self.name}"'
        lines = [line.strip() for line in xsetwacom("-s", "get", self.name, "all").split("\n")]
        lines = [line[len(prefix) :] for line in lines if line.startswith(prefix)]
        parameters = []
        for line in lines:
            items = [ll.strip() for ll in line.split('"')]
            items = [item for item in items if item]
            parameters.append((ParameterNames(items[0]),) + tuple(items[1:]))
        return parameters


def detect_devices() -> list[Device]:
    """
    Detect devices connected to this computer
    """
    devices = []

    for line in (ll.strip() for ll in xsetwacom.list().split("\n")):
        elements = [elem.strip() for elem in line.split("\t")]
        elements = [elem for elem in elements if elem]

        if not elements:
            continue

        name = elements[0].strip()
        id = elements[1].replace("id:", "").strip()
        device_type = DeviceType(elements[2].replace("type:", "").strip())
        devices.append(Device(name=name, id=id, device_type=device_type))

    return devices


devices = detect_devices()
for device in devices:
    print(device)
    parameters = device.get_parameters()
    # print(parameters)
    buttons = [p for p in parameters if p[0] == ParameterNames.Button]
    print(buttons)


@dataclass
class DeviceConfig:
    device: str
    pad: tuple[str, str, str, str]
    stylus: tuple[str, str, str]


def set_button_cmds(
    device_name: str,
    button_ids: Sequence[str],
    button_cmds: Sequence[str],
) -> None:
    """
    *button_cmds* applied to *button_ids* in order
    """
    for id, cmd in zip(sorted(button_ids), button_cmds):
        xsetwacom("--set", device_name, "Button", id, cmd)
        out_lines = xsetwacom("--get", device_name, "Button", id).strip()
        if cmd != out_lines:
            print(f"Tried to set {device_name} Button {id} to {cmd}, auto-corrected to {out_lines}")
        else:
            print(f"Set {device_name} Button {id} to {cmd}")


def apply_config(
    devices: list[Device],
    config: DeviceConfig,
) -> None:
    # TODO: GLOB?
    matching_devices = [d for d in devices if config.device.lower() in d.name.lower()]
    if not matching_devices:
        raise ValueError(
            f"Could not find device with name matching {config.device} in {[d.name for d in devices]}"
        )

    if len(matching_devices) < 1:
        raise ValueError(f"Only found 1 device: {matching_devices[0]}")
    elif len(matching_devices) > 2:
        raise ValueError(f"Found more than 2 devices matching {config.device}")

    # Find their type
    try:
        stylus = next(d for d in matching_devices if d.device_type == DeviceType.STYLUS)
        pad = next(d for d in matching_devices if d.device_type == DeviceType.PAD)
    except StopIteration:
        raise ValueError("Could not find PAD & STYLUS devices")

    stylus_parameters = stylus.get_parameters()
    print("Stylus buttons")
    current_stylus_map = {p[1]: p[2] for p in stylus_parameters if p[0] == ParameterNames.Button}

    set_button_cmds(
        device_name=stylus.name,
        button_ids=current_stylus_map.keys(),
        button_cmds=config.stylus,
    )

    pad_parameters = pad.get_parameters()
    current_pad_map = {p[1]: p[2] for p in pad_parameters if p[0] == ParameterNames.Button}

    set_button_cmds(
        device_name=pad.name,
        button_ids=current_pad_map.keys(),
        button_cmds=config.pad,
    )


gromit_config = DeviceConfig(
    device="intuos",
    pad=(
        "key +F9 -F9",
        "key +Control_L +F9 -F9",
        "key +F10 -F10",
        "key +Shift_L +F9 -F9",
    ),
    stylus=(
        "button +1",
        "button +1 key +Shift_L",
        "button +1 key +Control_L",
    ),
)

config = gromit_config


apply_config(devices, config)

# https://pygobject.gnome.org/
# Using dconf?
# from gi.repository import Gio,GLib

# class GnomeScreenLock:
#
#   IDLE_DELAY_SCHEMA = 'org.gnome.desktop.session'
#   IDLE_DELAY_KEY = 'idle-delay'
#
#   IDLE_ACTIVATION_SCHEMA = 'org.gnome.desktop.screensaver'
#   IDLE_ACTIVATION_KEY = 'idle-activation-enabled'
#
#   def getIdleDelay(self):
#         gsettings = Gio.Settings.new(self.IDLE_DELAY_SCHEMA)
#         return gsettings.get_value(self.IDLE_DELAY_KEY).get_uint32()
#
#   def setIdleDelay(self,delaySeconds):
#         gsettings = Gio.Settings.new(self.IDLE_DELAY_SCHEMA)
#         gsettings.set_value(self.IDLE_DELAY_KEY,GLib.Variant.new_uint32(delaySeconds))
#
#   def isIdleActivationEnabled(self):
#         gsettings = Gio.Settings.new(self.IDLE_ACTIVATION_SCHEMA)
#         return gsettings.get_boolean(self.IDLE_ACTIVATION_KEY)
#
#   def setIdleActivationStatus(self,activation):
#         gsettings = Gio.Settings.new(self.IDLE_ACTIVATION_SCHEMA)
#         gsettings.set_boolean(self.IDLE_ACTIVATION_KEY,activation)
