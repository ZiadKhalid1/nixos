#!/usr/bin/env bash

# Compress a video using a preset: 'share' (small size) or 'high' (better quality)

compress() {
  local preset="$1"
  local input="$2"
  local output="$3"

  if [[ "$preset" == "--help" || "$preset" == "-h" ]]; then
    echo "Usage: compress <preset> <input.mp4> <output.mp4>"
    echo
    echo "Presets:"
    echo "  share   - Smaller file size, optimized for messaging or social media (lower quality)"
    echo "            Uses: crf=28, maxrate=1M, bufsize=1M"
    echo
    echo "  high    - Better video quality, suitable for archiving or upload (larger file)"
    echo "            Uses: crf=20, maxrate=4M, bufsize=4M"
    echo
    echo "Examples:"
    echo "  compress share myvideo.mp4 out.mp4"
    echo "  compress high  movie.mkv   compressed.mkv"
    return 0
  fi

  if [ $# -ne 3 ]; then
    echo "Error: Invalid arguments."
    echo "Run 'compress --help' for usage."
    return 1
  fi

  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg is not installed." >&2
    return 2
  fi

  if [ ! -f "$input" ]; then
    echo "Error: Input file '$input' not found." >&2
    return 3
  fi

  # Set ffmpeg options based on preset
  case "$preset" in
    share)
      crf=28
      maxrate="1M"
      bufsize="1M"
      ;;
    high)
      crf=20
      maxrate="4M"
      bufsize="4M"
      ;;
    *)
      echo "Unknown preset: '$preset'. Use 'share' or 'high'."
      echo "Run 'compress --help' for more info."
      return 4
      ;;
  esac

  echo "Compressing '$input' → '$output' using '$preset' preset..."

  ffmpeg -y \
    -i "$input" \
    -crf "$crf" \
    -maxrate "$maxrate" \
    -bufsize "$bufsize" \
    -vf format=yuv420p \
    "$output"

  echo "✅ Done."
}

compress "$@"
