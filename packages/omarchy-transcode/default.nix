# NixOS-native equivalent of Omarchy's `omarchy-transcode`, provided under the
# same command name so Omarchy's vendored nautilus-python `transcode.py`
# extension (see modules/nixos/roles/desktop/addons/nautilus) can drive it.
#
# Differences from upstream: interactive pickers use `gum` instead of
# `omarchy-menu-*`, and notifications use `notify-send` instead of
# `omarchy-notification-send`. The magick/ffmpeg pipelines mirror upstream.
{
  lib,
  writeShellApplication,
  imagemagick,
  ffmpeg,
  wl-clipboard,
  gum,
  libnotify,
  coreutils,
  file,
}:
writeShellApplication {
  name = "omarchy-transcode";

  runtimeInputs = [
    imagemagick # magick
    ffmpeg
    wl-clipboard # wl-copy
    gum # interactive pickers
    libnotify # notify-send
    coreutils # dirname/basename/realpath
    file # mime detection
  ];

  text = ''
    usage() {
      cat <<'EOF'
    Usage: omarchy-transcode [input] [format] [resolution]

    With no input, pick a picture or video interactively. Then pick the output
    format and resolution (prompted when omitted).

    Formats:     Pictures: jpg, png     Videos: mp4, gif
    Resolutions: Pictures: high, medium, low     Videos: 4k, 1080p, 720p
    EOF
    }

    media_type() {
      local mime
      mime=$(file -b --mime-type "$1")
      case "$mime" in
        image/*) echo picture ;;
        video/*) echo video ;;
        *) echo "Unsupported file type: $mime" >&2; return 1 ;;
      esac
    }

    output_path() {
      local input="$1" format="$2" resolution="$3"
      local dir base stem
      dir=$(dirname -- "$input")
      base=$(basename -- "$input")
      stem="''${base%.*}"
      printf '%s/%s-%s.%s' "$dir" "$stem" "$resolution" "$format"
    }

    transcode_picture() {
      local input="$1" format="$2" resolution="$3" output="$4" resize
      case "$resolution" in
        high) resize='3160x>' ;;
        medium) resize='2160x>' ;;
        low) resize='1080x>' ;;
        *) echo "Invalid picture resolution: $resolution" >&2; return 1 ;;
      esac
      case "$format" in
        jpg) magick "$input" -resize "$resize" -quality 85 -strip "$output" ;;
        png)
          magick "$input" -resize "$resize" -strip \
            -define png:compression-filter=5 \
            -define png:compression-level=9 \
            -define png:compression-strategy=1 \
            -define png:exclude-chunk=all \
            "$output"
          ;;
        *) echo "Invalid picture format: $format" >&2; return 1 ;;
      esac
    }

    transcode_video() {
      local input="$1" format="$2" resolution="$3" output="$4" scale
      case "$resolution" in
        4k) scale='scale=-2:2160' ;;
        1080p) scale='scale=-2:1080' ;;
        720p) scale='scale=-2:720' ;;
        *) echo "Invalid video resolution: $resolution" >&2; return 1 ;;
      esac
      case "$format" in
        mp4)
          if [[ $resolution == "4k" ]]; then
            ffmpeg -i "$input" -vf "$scale" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k -movflags +faststart "$output"
          else
            ffmpeg -i "$input" -vf "$scale" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 192k -movflags +faststart "$output"
          fi
          ;;
        gif) ffmpeg -i "$input" -vf "fps=10,$scale:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$output" ;;
        *) echo "Invalid video format: $format" >&2; return 1 ;;
      esac
    }

    copy_to_clipboard() {
      local output="$1" uri
      uri="file://$(realpath -- "$output")"
      printf '%s\n' "$uri" | wl-copy --type text/uri-list
    }

    main() {
      local input="''${1:-}" format="''${2:-}" resolution="''${3:-}"
      local type output

      case "''${1:-}" in
        -h | --help) usage; return 0 ;;
      esac

      if [[ -z $input ]]; then
        input=$(gum file --file "$HOME") || return 1
      fi
      [[ -n $input ]] || return 1
      [[ -f $input ]] || { echo "File not found: $input" >&2; return 1; }

      type=$(media_type "$input")

      if [[ -z $format ]]; then
        if [[ $type == "picture" ]]; then
          format=$(gum choose --header "Select format" jpg png)
        else
          format=$(gum choose --header "Select format" mp4 gif)
        fi
      fi

      if [[ -z $resolution ]]; then
        if [[ $type == "picture" ]]; then
          resolution=$(gum choose --header "Select resolution" high medium low)
        else
          resolution=$(gum choose --header "Select resolution" 4k 1080p 720p)
        fi
      fi

      output=$(output_path "$input" "$format" "$resolution")

      if [[ $type == "video" ]]; then
        notify-send "Transcoding video…" "$(basename -- "$input") to $format ($resolution)"
        transcode_video "$input" "$format" "$resolution" "$output"
      else
        transcode_picture "$input" "$format" "$resolution" "$output"
      fi

      copy_to_clipboard "$output"
      notify-send "Transcoded to $resolution $format" "Saved and copied to clipboard."
      echo "Saved: $output"
    }

    main "$@"
  '';

  meta = with lib; {
    description = "Transcode pictures and videos for sharing (NixOS-native omarchy-transcode)";
    platforms = platforms.linux;
  };
}
