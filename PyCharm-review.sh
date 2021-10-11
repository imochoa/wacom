#!/bin/bash

# Load environment
. "/opt/wacom/env.sh"
[ $? -ne 0 ] && echo "...Failed to load /opt/wacom/env.sh!" && return 2 

# Configure the Stylus
# set_stylus_click     " button +1                "  " Click: draw RED                " ;
# set_stylus_lower_btn " button +1 key +Shift_L   "  " Click+Lower Button: draw GREEN " ;
# set_stylus_upper_btn " button +1 key +Control_L "  " Click+Upper Button: draw BLUE  " ;

# Configure the Pad
set_pad_btn_1   " key +Shift_L +F7 -F7 "  " prev. change " ;
set_pad_btn_2   " key  +F7 -F7         "  " next. change " ;
# set_pad_btn_3 " key +F10 -F10        "  " Undo         " ;
# set_pad_btn_4 " key +Shift_L +F9 -F9 "  " Clear screen " ;

