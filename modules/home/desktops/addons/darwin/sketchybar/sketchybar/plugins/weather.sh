#!/usr/bin/env zsh

IP=$(curl -s https://ipinfo.io/ip)
LOCATION_JSON=$(curl -s https://ipinfo.io/$IP/json)

LOCATION="$(echo $LOCATION_JSON | jq -r '.city')"
REGION="$(echo $LOCATION_JSON | jq -r '.region')"
COUNTRY="$(echo $LOCATION_JSON | jq  -r '.country')"

# Line below replaces spaces with +
LOCATION_ESCAPED="${LOCATION// /+}+${REGION// /+}"
WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION_ESCAPED?format=j1")

# Fallback if empty
if [ -z $WEATHER_JSON ]; then
  sketchybar --set $NAME label=$LOCATION
  sketchybar --set $NAME.weather icon=􀇚  # questionmark.circle as fallback
  return
fi

TEMPERATURE=$(echo $WEATHER_JSON | jq -r '.current_condition[0].FeelsLikeF')
WEATHER_DESCRIPTION=$(echo $WEATHER_JSON | jq -r '.current_condition[0].weatherDesc[0].value' | sed 's/\(.\{25\}\).*/\1.../')
WEATHER_CODE=$(echo $WEATHER_JSON | jq -r '.current_condition[0].weatherCode')

# Weather icon selection based on weather code
# https://www.worldweatheronline.com/feed/wwoConditionCodes.txt
case $WEATHER_CODE in
  113) # Clear/Sunny
    WEATHER_ICON=􀆮 # sun.max.fill
    ;;
  116) # Partly Cloudy
    WEATHER_ICON=􀇕 # cloud.sun.fill
    ;;
  119|122) # Cloudy/Overcast
    WEATHER_ICON=􀇃 # cloud.fill
    ;;
  143|248|260) # Fog/Mist
    WEATHER_ICON=􀇍 # cloud.fog.fill
    ;;
  263|266|281|284) # Drizzle
    WEATHER_ICON=􀇉 # cloud.drizzle.fill
    ;;
  176|293|296|299|302|305|308) # Rain variants
    WEATHER_ICON=􀇇 # cloud.rain.fill
    ;;
  353|356|359) # Rain showers
    WEATHER_ICON=􀇇 # cloud.rain.fill
    ;;
  182|185|311|314|317|320|362|365) # Sleet variants
    WEATHER_ICON=􀇏 # cloud.sleet.fill
    ;;
  179|323|326|329|332|335|338|368|371) # Snow variants
    WEATHER_ICON=􀇋 # cloud.snow.fill
    ;;
  200|386|389|392|395) # Thunderstorm variants
    WEATHER_ICON=􀇌 # cloud.bolt.rain.fill
    ;;
  350|374|377) # Ice pellets
    WEATHER_ICON=􀇑 # cloud.hail.fill
    ;;
  227|230) # Blizzard
    WEATHER_ICON=􀇋 # cloud.snow.fill
    ;;
  *)
    WEATHER_ICON=􀇚 # questionmark.circle as fallback
    ;;
esac

LABEL="$LOCATION  $TEMPERATURE􂧣 "

sketchybar --set $NAME \
  label="$LABEL" \
  icon="$WEATHER_ICON" \

