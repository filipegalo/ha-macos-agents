# shellcheck shell=bash
# Shared helpers for the agents. Source this file; do not run it.
#
# Configuration is read from $HA_AGENTS_CONFIG, default
# ~/.config/ha-macos-agents/config (see config.example). The access token is
# never stored in a file: it is read from the login Keychain.

set -euo pipefail

HA_AGENTS_CONFIG="${HA_AGENTS_CONFIG:-$HOME/.config/ha-macos-agents/config}"
HA_AGENTS_STATE_DIR="${HA_AGENTS_STATE_DIR:-$HOME/Library/Caches/ha-macos-agents}"

die() {
    echo "$(basename "$0"): $*" >&2
    exit 1
}

[[ -r "$HA_AGENTS_CONFIG" ]] || die "missing config $HA_AGENTS_CONFIG (copy config.example)"
# shellcheck source=/dev/null
source "$HA_AGENTS_CONFIG"

[[ -n "${HA_URL:-}" ]] || die "HA_URL is not set in $HA_AGENTS_CONFIG"
HA_URL="${HA_URL%/}"
HA_KEYCHAIN_SERVICE="${HA_KEYCHAIN_SERVICE:-ha-macos-agents}"

ha_token() {
    security find-generic-password -a "$USER" -s "$HA_KEYCHAIN_SERVICE" -w 2>/dev/null \
        || die "no token in Keychain service '$HA_KEYCHAIN_SERVICE' (run: make token)"
}

# ha_call DOMAIN SERVICE JSON — call a Home Assistant action.
ha_call() {
    curl -fsS --max-time 10 -o /dev/null -X POST \
        -H "Authorization: Bearer $(ha_token)" \
        -H "Content-Type: application/json" \
        -d "$3" \
        "$HA_URL/api/services/$1/$2"
}

# require_var NAME — fail unless the config sets NAME.
require_var() {
    [[ -n "${!1:-}" ]] || die "$1 is not set in $HA_AGENTS_CONFIG"
}
