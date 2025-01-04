#!/usr/bin/env sh

echo "called with $1"
echo "$FOCUSED_WORKSPACE"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  echo "INFO: $INFO"
  sketchybar --set $NAME background.drawing=on
fi
