#!/usr/bin/env zsh

sketchybar --add item weather q \
  --set weather \
  icon=􀇬\
  icon.color=$ACCENT_COLOR \
  background.padding_right=15 \
  update_freq=1800 \
  script="$PLUGIN_DIR/weather.sh" \
  --subscribe weather system_woke
