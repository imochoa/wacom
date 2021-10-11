#!/bin/bash

# Should be at /opt/wacom/env.sh
# SHOULD BE SOURCED NOT EXECUTED!

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Common functions
# ----------------------------------------------------------------------------------------- #
_log() { printf "$1$2${NC}\n"; }
log_debug() { _log ${GREEN} "$1"; }
log_info() { _log ${CYAN} "$1"; }
log_err() { _log ${RED} "$1"; }


# Global vars
DESC_CONCAT="";
# TODO padding?
L_MARGIN="          ";

_set_wacom_btn() {
  # Set the value
  device=$1
  btn=$2
  vals=$3
  desc=$4

  # Set
  log_info "[in] ${desc}"
  xsetwacom --set "${device}" "Button" "${btn}" "${vals} " 

  # Confirm its value (they auto-correct inputs, so this helps get feedback)
  res=$(xsetwacom --get "${device}" "Button" "${btn}")
  log_debug "  └──[out] ${device} ${btn}: [${res}]"


  # Concatenate all config calls for a report at the end...
  DESC_CONCAT="${DESC_CONCAT}\n${desc}"
  # TODO padding?
  # DESC_CONCAT="${DESC_CONCAT}\n${L_MARGIN:${#desc}} ${desc}"

}

# Any INTUOS Tablets available?
# ----------------------------------------------------------------------------------------- #
INTUOS_DEVICES=$(xsetwacom --list devices | grep "Intuos");

if [ -z "${INTUOS_DEVICES}" ];
then
  log_err "No Intuos devices found!";
  notify-send \
    --urgency=critical \
    --expire-time=2000 \
    --app-name="wacom" \
    "No Intuos devices found!";
  return 1;
   # exit; # kills shell
else
    COUNT=$(printf "${INTUOS_DEVICES}\n" | wc -l);
    log_debug "Found [${COUNT}] INTUOS devices";
fi

# Find the Intuos devices 
# ----------------------------------------------------------------------------------------- #
STYLUS=$(printf "${INTUOS_DEVICES}" | grep 'STYLUS *$' | cut -d: -f1 | rev | cut -c 3- | rev | xargs )
PAD=$(printf "${INTUOS_DEVICES}" | grep 'PAD *$' | cut -d: -f1 | rev | cut -c 3- | rev | xargs )
# Feedback
[ -z "${STYLUS}" ] && log_err "\t[X] Could not find the stylus!";
[ -z "${PAD}" ] && log_err "\t[X] Could not find the pad!";

# Stylus fcns
# ----------------------------------------------------------------------------------------- #
STY_CLICK="1"
STY_LOWERB="2"
STY_UPPERB="3"
set_stylus_click(){ _set_wacom_btn "${STYLUS}" "${STY_CLICK}" "$1 " "Stylus, click: ${2:-[no description]}"; }
set_stylus_lower_btn(){ _set_wacom_btn "${STYLUS}" "${STY_LOWERB}" "$1 " "Stylus, lower B: ${2:-[no description]}"; }
set_stylus_upper_btn(){ _set_wacom_btn "${STYLUS}" "${STY_UPPERB}" "$1 " "Stylus, upper B: ${2:-[no description]}"; }

# Pad fcns
# ----------------------------------------------------------------------------------------- #
PAD_B1="1"
PAD_B2="2"
PAD_B3="3"
PAD_B4="8"
set_pad_btn_1(){ _set_wacom_btn "${PAD}" "${PAD_B1}" "$1 " "Pad, B1: ${2:-[no description]}"; }
set_pad_btn_2(){ _set_wacom_btn "${PAD}" "${PAD_B2}" "$1 " "Pad, B2: ${2:-[no description]}"; }
set_pad_btn_3(){ _set_wacom_btn "${PAD}" "${PAD_B3}" "$1 " "Pad, B3: ${2:-[no description]}"; }
set_pad_btn_4(){ _set_wacom_btn "${PAD}" "${PAD_B4}" "$1 " "Pad, B4: ${2:-[no description]}"; }

# Report on exit
# ----------------------------------------------------------------------------------------- #
trap 'notify-send --expire-time=10000 --app-name="wacom" "${PAD}" "${DESC_CONCAT}"' EXIT
