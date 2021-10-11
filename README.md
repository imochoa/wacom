# wacom

A set of configs for my wacom tablets and scripts to set them up

## Setup

The config scripts look like:

```shell
#!/bin/bash

# Configure the Stylus
set_stylus_click     " button +1                "  " Click: draw RED                " ;
set_stylus_lower_btn " button +1 key +Shift_L   "  " Click+Lower Button: draw GREEN " ;
set_stylus_upper_btn " button +1 key +Control_L "  " Click+Upper Button: draw BLUE  " ;

# Configure the Pad
set_pad_btn_1 " key +F9 -F9            "  " Draw ON/OFF       " ;
set_pad_btn_2 " key +Control_L +F9 -F9 "  " Visibility ON/OFF " ;
set_pad_btn_3 " key +F10 -F10          "  " Undo              " ;
set_pad_btn_4 " key +Shift_L +F9 -F9   "  " Clear screen      " ;

```

### Why bash?

It doesn't really matter what shell you use, but I'm trying to add left padding

### What are the functions

```shell
set_xyz_btn "key combination to run" "explanation to show";
```

There are 7 functions (since that's what my tablet has)

```shell
set_stylus_click
set_stylus_lower_btn
set_stylus_upper_btn
set_pad_btn_1
set_pad_btn_2
set_pad_btn_3
set_pad_btn_4

```

### Location of env.sh

### Calling it with a function

```shell
toggle_wacom (){

\ls /opt/wacom/configs/ \
  | rofi -dmenu \
  -window-title "choose yo" \
  -mesg "wacom buttons" \
  | xargs -I% realpath /opt/wacom/configs/% \
  | xargs -I% bash -c '. "%" && echo "Chose %"'
}
```
