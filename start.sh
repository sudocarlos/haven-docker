#!/usr/bin/env bash
set -e

# --- Validate required env vars ---
missing=()
[[ -z "$OWNER_NPUB" ]]  && missing+=("OWNER_NPUB")
[[ -z "$RELAY_URL" ]]   && missing+=("RELAY_URL")
if [[ ${#missing[@]} -gt 0 ]]; then
	echo "ERROR: missing required env vars: ${missing[*]}" >&2
	exit 1
fi

# --- Signal handling ---
cleanup() {
	echo "Shutting down..."
	[[ -n "$TOR_PID" ]] && kill "$TOR_PID" 2>/dev/null
	wait
}
trap cleanup SIGTERM SIGINT

# --- Optional Tor hidden service ---
if [[ "$TOR_ENABLED" == 1 ]]; then
	echo "HiddenServiceDir /var/lib/tor/haven/" >> /etc/tor/torrc
	echo "HiddenServicePort 80 ${RELAY_BIND_ADDRESS}:${RELAY_PORT}" >> /etc/tor/torrc
	tor &
	TOR_PID=$!
	echo "Tor started (PID $TOR_PID)"
fi

# --- Start Haven ---
cd /haven
exec ./haven