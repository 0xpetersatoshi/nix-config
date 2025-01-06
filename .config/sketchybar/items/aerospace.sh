#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change
sid = $(aerospace list-workspaces --focused)
sketchybar --add item space.aerospace left \
  --subscribe space.aerospace aerospace_workspace_change \
  --set space.aerospace \
  background.drawing=off \
  label.font.size=14.0 \
  label="$sid" \
  script="$PLUGIN_DIR/aerospace.sh"
