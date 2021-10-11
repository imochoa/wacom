# wacom

A set of configs for my wacom tablets and scripts to set them up

# INFO

```shell
toggle_wacom (){

\ls -I "env.sh" /opt/wacom/*.sh \
  | rofi -dmenu \
  -window-title "choose yo" \
  -mesg "wacom buttons" \
  | xargs -I% realpath /opt/% \
  | xargs -I% sh -c '. "%" && echo "Chose %"'
}

```
