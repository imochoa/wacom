#!/usr/bin/env sh

#!/bin/bash

# Load environment
. "/opt/wacom/env.sh"
[ $? -ne 0 ] && echo "...Failed to load /opt/wacom/env.sh!" && return 2 

# Configure the Stylus
set_stylus_click     " button +1                "  " Draw                " ;
set_stylus_lower_btn " key +Control_L +Shift_L +p "  " Change to pen " ;
set_stylus_upper_btn " key +Control_L +Shift_L +a "  " Change to hand  " ;

# Configure the Pad
# set_pad_btn_1 " key +F9 -F9            "  " Draw ON/OFF       " ;
# set_pad_btn_2 " key +Control_L +F9 -F9 "  " Visibility ON/OFF " ;
# set_pad_btn_3 " key +F10 -F10          "  " Undo              " ;
# set_pad_btn_4 " key +Shift_L +F9 -F9   "  " Clear screen      " ;


# undo, redo
# control Z 
# control Y


