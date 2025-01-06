#!/usr/bin/env sh

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  sketchybar --set $NAME label=$FOCUSED_WORKSPACE background.drawing=on
fi
