#!/usr/bin/env sh

# Load environment
. "/opt/wacom/env.sh"
[ $? -ne 0 ] && echo "...Failed to load /opt/wacom/env.sh!" && return 2 

# Configure the Stylus
set_stylus_click     " button +1                "  " Click: draw RED                " ;
set_stylus_lower_btn " button +1 key +Shift_L   "  " Click+Lower Button: draw GREEN " ;
set_stylus_upper_btn " button +1 key +Control_L "  " Click+Upper Button: draw BLUE  " ;

# Configure the Pad
set_pad_btn_1 " key +F9 -F9            "  " Draw ON/OFF       " ;
set_pad_btn_2 " key +Control_L +F9 -F9 "  " Visibility ON/OFF " ;
set_pad_btn_3 " key +F10 -F10          "  " Undo              " ;
set_pad_btn_4 " key +Shift_L +F9 -F9   "  " Clear screen      " ;
