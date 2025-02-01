#!/usr/bin/env sh

STATE="$(echo "$INFO" | jq -r '.state')"
APP="$(echo "$INFO" | jq -r '.app')"

case $APP in
"Music")
  ICON="􀒷"
  ICON_COLOR="0xfffc3c44"
  ;;
"Spotify")
  ICON=""
  ICON_COLOR="0xff1db954"
  ;;
esac

if [ "$STATE" = "playing" ]; then
  MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
  sketchybar --set $NAME label="$MEDIA" drawing=on icon="$ICON" icon.color="$ICON_COLOR"
else
  sketchybar --set $NAME drawing=off
fi
