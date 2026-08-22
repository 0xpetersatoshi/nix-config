# Take a screenshot. Ported from Omarchy's `omarchy-capture-screenshot`.
#
#   Usage: omarchy-capture-screenshot [smart|region|windows|fullscreen] \
#                                     [slurp|copy|save] [--editor=<name>]
#
# Differences from upstream: notifications go through notify-send with a
# standard libnotify action (Omarchy uses a custom hint understood only by its
# own Quickshell daemon), and the cursor option is set with `hyprctl keyword`
# since `hyprctl eval` needs Hyprland's Lua config manager.

# shellcheck source=/dev/null
[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
# Honour XDG_SCREENSHOTS_DIR (set by xdg.userDirs) before falling back to
# Pictures/Screenshots, so shots do not pile up in the Pictures root.
OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_SCREENSHOTS_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots}}"

if [[ ! -d $OUTPUT_DIR ]]; then
  mkdir -p "$OUTPUT_DIR"
  notify-send -t 2000 "Created screenshot directory: $OUTPUT_DIR"
fi

# A second press while the picker is up cancels it.
pkill slurp && exit 0

SCREENSHOT_EDITOR="${OMARCHY_SCREENSHOT_EDITOR:-tensaku-edit}"

# Parse --editor flag from any position
ARGS=()
for arg in "$@"; do
  if [[ $arg == --editor=* ]]; then
    SCREENSHOT_EDITOR="${arg#--editor=}"
  else
    ARGS+=("$arg")
  fi
done
set -- "${ARGS[@]}"

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

# The picker leaves the screen freeze running (PID on its first output line)
# so grim captures the frozen overlay rather than live content shifting
# during teardown.
#
# Software-composited cursors (Hyprland's fallback on GPUs without working
# hardware cursors) are baked into the frames grim captures, so force
# hardware cursors until after grim runs and restore the setting on exit.
NO_HW_CURSORS=$(hyprctl getoption cursor:no_hardware_cursors -j | jq '.int')

set_no_hw_cursors() {
  hyprctl keyword cursor:no_hardware_cursors "$1" &>/dev/null
}

cleanup() {
  [[ -n ${FREEZE_PID:-} ]] && kill "$FREEZE_PID" 2>/dev/null
  set_no_hw_cursors "$NO_HW_CURSORS"
}
trap cleanup EXIT

set_no_hw_cursors 0
{ read -r FREEZE_PID; read -r SELECTION; } < <(omarchy-capture-region "$MODE" --keep-freeze)

[[ -z ${SELECTION:-} ]] && exit 0

FILENAME="screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# Fires the editor when the toast (or its Edit button) is clicked. notify-send
# blocks until the notification is actioned or expires, so this runs detached
# and must not hold up the capture.
notify_with_edit_action() {
  local filepath=$1
  local chosen
  chosen=$(notify-send \
    --app-name=screenshot \
    --icon="$filepath" \
    --hint="string:image-path:$filepath" \
    --action=edit=Edit \
    --wait \
    "Screenshot saved to clipboard and file" \
    "Click to edit" 2>/dev/null) || return 0

  [[ $chosen == "edit" ]] && setsid -f "$SCREENSHOT_EDITOR" "$filepath" >/dev/null 2>&1
  return 0
}

case "$PROCESSING" in
  slurp)
    grim -g "$SELECTION" "$FILEPATH" || exit 1
    echo "$FILEPATH"
    wl-copy --type image/png <"$FILEPATH"

    # Best-effort: the screenshot is already saved and on the clipboard, so a
    # notification outage must not report the capture itself as failed.
    ( notify_with_edit_action "$FILEPATH" & ) >/dev/null 2>&1 || true
    ;;
  copy)
    grim -g "$SELECTION" - | wl-copy --type image/png
    ;;
  save)
    grim -g "$SELECTION" "$FILEPATH" || exit 1
    echo "$FILEPATH"
    ;;
esac
