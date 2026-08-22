# Start or stop a screen recording. Ported from Omarchy's
# `omarchy-capture-screenrecording`.
#
#   Usage: omarchy-capture-screenrecording [--fullscreen]
#              [--with-desktop-audio] [--with-microphone-audio]
#              [--resolution=<WxH>] [--stop-recording]
#
# Running it with a recording already in flight stops that recording, so a
# single key can toggle. --stop-recording only ever stops (exits 1 when
# nothing is recording), which lets a binding fall through to something else.
#
# Env: OMARCHY_SCREENRECORD_USE_PORTAL=true skips the slurp picker and uses
# gpu-screen-recorder's xdg-desktop-portal backend instead (HDR, monitors on
# external GPUs, window capture). Off by default because the portal path can
# fail EGL DMA-BUF modifier import on some setups.
#
# Env: OMARCHY_SCREENRECORD_DEBUG=true logs gpu-screen-recorder's stderr to
# /tmp/omarchy-screenrecord.log.
#
# Differences from upstream: no webcam overlay, no Omarchy shell indicator, and
# notifications use a standard libnotify action instead of Omarchy's custom
# daemon hint.

# shellcheck source=/dev/null
[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${OMARCHY_SCREENRECORD_DIR:-${XDG_VIDEOS_DIR:-$HOME/Videos}}"

if [[ ! -d $OUTPUT_DIR ]]; then
  mkdir -p "$OUTPUT_DIR"
  notify-send -t 2000 "Created recording directory: $OUTPUT_DIR"
fi

SCRIPT_ARGS="$*"

# Match gpu-screen-recorder by path suffix rather than upstream's
# "^gpu-screen-recorder": runtimeInputs puts an absolute /nix/store path in the
# process cmdline, so an anchored basename never matches and the toggle could
# neither detect nor stop a recording. The trailing "( |$)" keeps this from
# also matching gpu-screen-recorder-gtk.
GSR_PATTERN='gpu-screen-recorder( |$)'

DESKTOP_AUDIO="false"
MICROPHONE_AUDIO="false"
RESOLUTION=""
FULLSCREEN="false"
STOP_RECORDING="false"
RECORDING_FILE="/tmp/omarchy-screenrecord-filename"
LOG_FILE=$([[ ${OMARCHY_SCREENRECORD_DEBUG:-false} == "true" ]] && echo "/tmp/omarchy-screenrecord.log" || echo "/dev/null")

for arg in "$@"; do
  case "$arg" in
  --with-desktop-audio) DESKTOP_AUDIO="true" ;;
  --with-microphone-audio) MICROPHONE_AUDIO="true" ;;
  --resolution=*) RESOLUTION="${arg#*=}" ;;
  --fullscreen) FULLSCREEN="true" ;;
  --stop-recording) STOP_RECORDING="true" ;;
  esac
done

focused_monitor_name() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

default_resolution() {
  local width height
  read -r width height < <(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
  if ((width > 3840 || height > 2160)); then
    echo "3840x2160"
  else
    echo "0x0"
  fi
}

# Echoes "monitor:NAME" when the selection matches an entire monitor (prefer
# -w <monitor> over a region capture -- same kms backend, but no scaling math
# and full native res), otherwise "region:WxH+X+Y". Returns non-zero if the
# user cancelled the picker.
select_capture_target() {
  local target
  target=$(omarchy-capture-region smart --match-monitor) || return 1

  if [[ $target == monitor:* ]]; then
    echo "$target"
    return
  fi

  [[ $target =~ ^(-?[0-9]+),(-?[0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] || return 1

  # gpu-screen-recorder wants region geometry in the compositor's logical
  # coordinate space -- the same space slurp returns -- so pass the values
  # through untouched (gsr scales to physical pixels itself).
  echo "region:${BASH_REMATCH[3]}x${BASH_REMATCH[4]}+${BASH_REMATCH[1]}+${BASH_REMATCH[2]}"
}

start_screenrecording() {
  local capture_args=()
  local target

  if [[ $FULLSCREEN == "true" ]]; then
    target="monitor:$(focused_monitor_name)"
    capture_args=(-w "${target#monitor:}" -s "${RESOLUTION:-$(default_resolution)}")
  elif [[ ${OMARCHY_SCREENRECORD_USE_PORTAL:-false} == "true" ]]; then
    target="portal"
    capture_args=(-w portal -s "${RESOLUTION:-$(default_resolution)}")
  else
    target=$(select_capture_target) || return 1

    case $target in
    monitor:*)
      capture_args=(-w "${target#monitor:}" -s "${RESOLUTION:-$(default_resolution)}")
      ;;
    region:*)
      capture_args=(-w "${target#region:}")
      [[ -n $RESOLUTION ]] && capture_args+=(-s "$RESOLUTION")
      ;;
    esac
  fi

  local filename
  filename="$OUTPUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"
  local audio_devices=""
  local audio_args=()

  [[ $DESKTOP_AUDIO == "true" ]] && audio_devices+="default_output"

  if [[ $MICROPHONE_AUDIO == "true" ]]; then
    # Merge audio tracks into one - separate tracks only play one at a time in
    # most players.
    [[ -n $audio_devices ]] && audio_devices+="|"
    audio_devices+="default_input"
  fi

  [[ -n $audio_devices ]] && audio_args+=(-a "$audio_devices" -ac aac)

  echo "===== $(date '+%F %T') args: $SCRIPT_ARGS target: $target =====" >>"$LOG_FILE"
  gpu-screen-recorder "${capture_args[@]}" -k auto -f 60 -fm cfr -fallback-cpu-encoding yes -o "$filename" "${audio_args[@]}" 2>>"$LOG_FILE" &
  local pid=$!

  while kill -0 $pid 2>/dev/null && [[ ! -f $filename ]]; do
    sleep 0.2
  done

  if kill -0 $pid 2>/dev/null; then
    echo "$filename" >"$RECORDING_FILE"
    notify-send --app-name=screenrecording -t 2000 "Recording started" "Press the same key again to stop"
  fi
}

# Fires mpv when the toast (or its Play button) is clicked. notify-send blocks
# until the notification is actioned or expires, so this runs detached.
notify_with_play_action() {
  local filename=$1 preview=$2 chosen
  chosen=$(notify-send \
    --app-name=screenrecording \
    --icon="$preview" \
    --hint="string:image-path:$preview" \
    --action=play=Play \
    -t 10000 \
    "Screen recording saved" \
    "Click to play" 2>/dev/null) || return 0

  [[ $chosen == "play" ]] && setsid -f mpv "$filename" >/dev/null 2>&1
  return 0
}

stop_screenrecording() {
  pkill -SIGINT -f "$GSR_PATTERN" # SIGINT required to save video properly

  # Wait a maximum of 5 seconds to finish before hard killing
  local count=0
  while pgrep -f "$GSR_PATTERN" >/dev/null && ((count < 50)); do
    sleep 0.1
    count=$((count + 1))
  done

  if pgrep -f "$GSR_PATTERN" >/dev/null; then
    pkill -9 -f "$GSR_PATTERN"
    notify-send -u critical -t 5000 "Screen recording error" "Recording process had to be force-killed. Video may be corrupted."
  else
    finalize_recording
    local filename
    filename=$(cat "$RECORDING_FILE" 2>/dev/null)
    echo "$filename"
    local preview="${filename%.mp4}-preview.png"

    # Generate a preview thumbnail from the first frame
    ffmpeg -y -i "$filename" -ss 00:00:00.1 -vframes 1 -q:v 2 "$preview" -loglevel quiet 2>/dev/null

    ( notify_with_play_action "$filename" "${preview:-$filename}" & ) >/dev/null 2>&1 || true

    # The shell loads the thumbnail into memory when the toast appears and never
    # re-reads the file, so the preview only has to outlive that load -- not the
    # toast. Clear it out of the recordings directory a moment later.
    (
      sleep 2
      rm -f "$preview"
    ) &
  fi

  rm -f "$RECORDING_FILE"
}

screenrecording_active() {
  pgrep -f "$GSR_PATTERN" >/dev/null
}

finalize_recording() {
  local latest
  latest=$(cat "$RECORDING_FILE" 2>/dev/null)
  [[ -f $latest ]] || return

  # Re-encode only when the first GOP contains discardable warmup packets --
  # stream copy can't trim those (it rewinds to the keyframe). Clean recordings
  # stay on the fast stream-copy path.
  local video_codec=(-c:v copy)
  if ffprobe -v error -select_streams v:0 -read_intervals %+0.2 -show_entries packet=flags -of csv=p=0 "$latest" 2>/dev/null | grep -q D; then
    video_codec=(-c:v libx264 -preset veryfast -crf 20)
  fi

  # Trim the first frame, and normalize audio to -14 LUFS if present, in a
  # single pass.
  local args=(-y -ss 0.1 -i "$latest" "${video_codec[@]}")
  if ffprobe -v error -select_streams a -show_entries stream=codec_type -of csv=p=0 "$latest" 2>/dev/null | grep -q audio; then
    # Hard-mute the first 400ms to drop the PipeWire capture-open pop (a
    # near-clipping transient around 130-200ms that a gentle fade-in can't
    # attenuate enough), then a 50ms fade avoids a click at the boundary before
    # loudnorm normalizes the rest.
    args+=(-af "volume=enable='lt(t,0.4)':volume=0,afade=t=in:st=0.4:d=0.05,loudnorm=I=-14:TP=-1.5:LRA=11")
  fi

  local processed="${latest%.mp4}-processed.mp4"
  if ffmpeg "${args[@]}" "$processed" -loglevel quiet 2>/dev/null; then
    mv "$processed" "$latest"
  else
    rm -f "$processed"
  fi
}

if screenrecording_active; then
  stop_screenrecording
elif [[ $STOP_RECORDING == "true" ]]; then
  exit 1
else
  start_screenrecording
fi
