{ pkgs ? import <nixpkgs> {} }:

let
  unicodeData = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/pierrechevalier83/find_unicode/master/src/UnicodeData";
    sha256 = "03bwb2zi9lhvb5gaqm4283fwnv92vv6i6rsg40c4rrq0wkwhgbn9";
  };

  fuScript = pkgs.writeScript "fu" ''
    #!/usr/bin/env bash
    # fu - Find Unicode characters with ease
    #
    # Simply type a description of the character you are looking for. Once you found the character
    # you were after, hit Enter. Selecting multiple characters is also possible: hit tab to select a
    # character and continue browsing.

    set -euo pipefail

    UNICODE_DATA="@unicodeData@"

    # Default values
    SEARCH="regex"
    LAYOUT="below"
    HEIGHT="50%"
    COLOR=""
    INITIAL_QUERY=""

    usage() {
        cat <<EOF
    fu - Find Unicode characters with ease

    Simply type a description of the character you are looking for. Once you found the character
    you were after, hit Enter. Selecting multiple characters is also possible: hit tab to select a
    character and continue browsing.

    USAGE:
        fu [OPTIONS] [INITIAL_QUERY]

    ARGS:
        <INITIAL_QUERY>    Initial query, if any

    OPTIONS:
        --search <SEARCH>    Search mode [default: regex] [possible values: regex, exact, fuzzy]
        --layout <LAYOUT>    Position of fu's window relative to the prompt [default: below] [possible values: above, below]
        --height <HEIGHT>    Height of fu's window relative to the terminal window [default: 50%]
        --color <COLOR>      Color theme. Refer to fzf documentation for more info.
        -h, --help           Print help information
        -V, --version        Print version information
    EOF
    }

    version() {
        echo "fu 0.1.0"
    }

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --search=*)
                SEARCH="''${1#*=}"
                shift
                ;;
            --search)
                SEARCH="$2"
                shift 2
                ;;
            --layout=*)
                LAYOUT="''${1#*=}"
                shift
                ;;
            --layout)
                LAYOUT="$2"
                shift 2
                ;;
            --height=*)
                HEIGHT="''${1#*=}"
                shift
                ;;
            --height)
                HEIGHT="$2"
                shift 2
                ;;
            --color=*)
                COLOR="''${1#*=}"
                shift
                ;;
            --color)
                COLOR="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                usage >&2
                exit 1
                ;;
            *)
                INITIAL_QUERY="$1"
                shift
                ;;
        esac
    done

    # Build fzf options
    FZF_OPTS=()

    # Search mode
    # fzf uses extended-search by default (similar to regex)
    # --exact enables exact/substring matching
    # default (no flag) is fuzzy matching with extended search
    case "$SEARCH" in
        regex)
            # Extended search mode is the default in fzf, allows regex-like patterns
            # No additional flags needed
            ;;
        exact)
            FZF_OPTS+=("--exact")
            ;;
        fuzzy)
            # Disable extended search for pure fuzzy matching
            FZF_OPTS+=("--no-extended")
            ;;
        *)
            echo "Invalid search mode: $SEARCH" >&2
            exit 1
            ;;
    esac

    # Layout
    case "$LAYOUT" in
        below)
            FZF_OPTS+=("--reverse")
            ;;
        above)
            # Default fzf layout is above
            ;;
        *)
            echo "Invalid layout: $LAYOUT" >&2
            exit 1
            ;;
    esac

    # Height
    FZF_OPTS+=("--height=$HEIGHT")

    # Color
    if [[ -n "$COLOR" ]]; then
        FZF_OPTS+=("--color=$COLOR")
    fi

    # Multi-select and inline info
    FZF_OPTS+=("--multi" "--info=inline")

    # Initial query
    if [[ -n "$INITIAL_QUERY" ]]; then
        FZF_OPTS+=("--query=$INITIAL_QUERY")
    fi

    # Check if UnicodeData file exists
    if [[ ! -f "$UNICODE_DATA" ]]; then
        echo "Error: UnicodeData file not found at $UNICODE_DATA" >&2
        exit 1
    fi

    # Run fzf and output selected characters
    cat "$UNICODE_DATA" | fzf "''${FZF_OPTS[@]}" || true
  '';
in
pkgs.stdenv.mkDerivation rec {
  pname = "fu";
  version = "0.1.0";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/fu
    cp ${unicodeData} $out/share/fu/UnicodeData

    substitute ${fuScript} $out/bin/fu \
      --replace-warn '@unicodeData@' "$out/share/fu/UnicodeData"
    chmod +x $out/bin/fu

    wrapProgram $out/bin/fu \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.fzf ]}
  '';

  meta = with pkgs.lib; {
    description = "Find Unicode characters with ease";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "fu";
  };
}
