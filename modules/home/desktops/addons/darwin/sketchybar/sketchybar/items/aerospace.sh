#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change
sketchybar --add item space.aerospace left \
  --subscribe space.aerospace aerospace_workspace_change \
  --set space.aerospace \
  background.drawing=on \
  label.font.size=14.0 \
  icon.padding_left=10 \
  icon.padding_right=0 \
  label.padding_left=0 \
  label.padding_right=10 \
  label="$(aerospace list-workspaces --focused)" \
  script="$PLUGIN_DIR/aerospace.sh"
