#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change
for sid in $(aerospace list-workspaces --focused); do
  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" aerospace_workspace_change \
    --set space."$sid" \
    background.drawing=off \
    label.font.size=14.0 \
    label="$sid" \
    click_script="aerospace workspace $sid" \
    script="$PLUGIN_DIR/aerospace.sh $sid"
done
