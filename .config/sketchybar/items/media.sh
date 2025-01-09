#!/usr/bin/env sh

sketchybar --add item media e \
  --set media label.color=$ACCENT_COLOR \
  label.max_chars=20 \
  scroll_texts=on \
  icon=􀑪 \
  icon.color=$ACCENT_COLOR \
  background.drawing=on \
  background.padding_left=15 \
  script="$PLUGIN_DIR/media.sh" \
  --subscribe media media_change
