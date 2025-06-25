#!/usr/bin/env bash

# Git Helper Script - Generates conventional commit messages using OpenRouter AI
# Usage: git-helper.sh [--verbose]

set -euo pipefail

# === CONFIGURATION ===
CLIENT_ID="your-client-id"
REDIRECT_URI="http://localhost:8765/callback"
AUTH_URL="https://openrouter.ai/auth"
TOKEN_URL="https://openrouter.ai/api/v1/auth/keys"
CACHE_DIR="$HOME/.cache/openrouter"
CACHE_FILE="$CACHE_DIR/key"

# === LOGGING ===
VERBOSE=false
if [[ "${1:-}" == "--verbose" ]]; then
    VERBOSE=true
fi

log() {
    if [[ "$VERBOSE" == true ]]; then
        echo "[i] $1" >&2
    fi
}

error() {
    echo "[!] $1" >&2
    exit 1
}

success() {
    if [[ "$VERBOSE" == true ]]; then
        echo "[✅] $1" >&2
    fi
}

# === DEPENDENCY CHECK ===
check_dependencies() {
    local deps=("curl" "jq" "openssl" "nc" "git")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Required dependency '$dep' is not installed"
        fi
    done
}

# === OAUTH FUNCTIONS ===
start_oauth_flow() {
    log "OPENROUTER_API_KEY not set — initiating OAuth PKCE flow..."

    mkdir -p "$CACHE_DIR"

    # Generate PKCE code verifier and challenge
    local code_verifier
    code_verifier=$(openssl rand -base64 32 | tr -d '=+/' | tr -d '\n')
    local code_challenge
    code_challenge=$(echo -n "$code_verifier" | openssl dgst -sha256 -binary | openssl base64 | tr -d '=+/' | tr -d '\n')

    local auth_url="${AUTH_URL}?callback_url=${REDIRECT_URI}&code_challenge=${code_challenge}&code_challenge_method=S256"

    log "Opening browser for authentication..."
    if command -v xdg-open &> /dev/null; then
        xdg-open "$auth_url" 2>/dev/null &
    else
        echo "Please open this URL manually: $auth_url"
    fi

    log "Waiting for redirect with ?code=… on $REDIRECT_URI"
    local code
    code=$(timeout 120 nc -l 8765 | grep "GET /callback" | sed -n 's/.*code=\([^& ]*\).*/\1/p' || true)

    if [[ -z "$code" ]]; then
        error "Authorization code not received within timeout"
    fi

    log "Received authorization code"

    # Exchange code for API key
    local resp
    resp=$(curl -s -X POST "$TOKEN_URL" \
        -H "Content-Type: application/json" \
        -d "{\"code\":\"$code\",\"code_verifier\":\"$code_verifier\",\"code_challenge_method\":\"S256\"}")

    local api_key
    api_key=$(echo "$resp" | jq -r '.key')

    if [[ -z "$api_key" ]] || [[ "$api_key" == "null" ]]; then
        error "Failed to obtain API key: $resp"
    fi

    export OPENROUTER_API_KEY="$api_key"
    echo "$OPENROUTER_API_KEY" > "$CACHE_FILE"
    chmod 600 "$CACHE_FILE"
    success "API key obtained and cached"
}

# === MAIN LOGIC ===
main() {
    check_dependencies

    # Check for cached API key
    if [[ -z "${OPENROUTER_API_KEY:-}" ]] && [[ -f "$CACHE_FILE" ]]; then
        export OPENROUTER_API_KEY=$(<"$CACHE_FILE")
        log "Loaded cached API key"
    fi

    # Start OAuth flow if no key available
    if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
        start_oauth_flow
    fi

    # Check if there are staged changes
    if ! git diff --cached --quiet; then
        log "Analyzing staged changes..."

        # Get Git diff and prepare for API call
        local changes
        changes=$(git diff --cached | jq -Rs .)

        # Generate commit message
        local commit_msg
        commit_msg=$(curl -s https://openrouter.ai/api/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENROUTER_API_KEY" \
            -d "{
                \"model\":\"deepseek/deepseek-chat-v3-0324:free\",
                \"messages\":[
                    {
                        \"role\":\"system\",
			\"content\": \"You are a Git assistant specialized in writing high-quality, conventional commit messages. Your job is to generate concise, clear, and meaningful commit messages based on the provided git diff. Follow these rules:\\n\\n\\n2. Write in the imperative mood (e.g., 'Add', 'Fix', 'Update' — not 'Added' or 'Fixed').\\n3. Keep the commit summary under 80 characters if possible.\\n4. Only output the commit message.\\n5. Add a short description after the summary, separated by a blank line, if the change needs further context.\"

                    },
                    {
                        \"role\":\"user\",
                        \"content\":$changes
                    }
                ]
            }" | jq -r '.choices[0].message.content')

        if [[ -n "$commit_msg" ]] && [[ "$commit_msg" != "null" ]]; then
            echo "$commit_msg"
        else
            error "Failed to generate commit message"
        fi
    else
        error "No staged changes found. Use 'git add' to stage changes first."
    fi
}

main "$@"
