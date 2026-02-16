#!/usr/bin/env bash
#
# Automated tests for the haven-docker image.
# Validates build, healthcheck, env validation, and basic functionality.
#
# Usage:  bash tests/test-image.sh
# Output: TAP-style (Test Anything Protocol)
#
set -euo pipefail

# ── Globals ───────────────────────────────────────────────
IMAGE="haven-test:$$"
CONTAINER=""
PASS=0
FAIL=0
TEST_NUM=0
TOTAL_TESTS=9

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DATA_DIR=$(mktemp -d)

# ── Helpers ───────────────────────────────────────────────
cleanup() {
  if [[ -n "$CONTAINER" ]]; then
    docker rm -f "$CONTAINER" &>/dev/null || true
  fi
  docker rmi -f "$IMAGE" &>/dev/null || true
  # Container creates root-owned files; use docker to clean them
  if [[ -d "$TEST_DATA_DIR" ]]; then
    docker run --rm -v "$TEST_DATA_DIR:/cleanup" alpine rm -rf /cleanup/* 2>/dev/null || true
    rm -rf "$TEST_DATA_DIR" 2>/dev/null || true
  fi
}
trap cleanup EXIT

pass() {
  TEST_NUM=$((TEST_NUM + 1))
  PASS=$((PASS + 1))
  echo "ok $TEST_NUM - $1"
}

fail() {
  TEST_NUM=$((TEST_NUM + 1))
  FAIL=$((FAIL + 1))
  echo "not ok $TEST_NUM - $1"
  [[ -n "${2:-}" ]] && echo "#   $2"
}

header() {
  echo ""
  echo "# $1"
}

# ── Test 1: Build succeeds ────────────────────────────────
header "Building image..."
if docker build --load -t "$IMAGE" "$PROJECT_DIR" > /dev/null 2>&1; then
  pass "Docker image builds successfully"
else
  fail "Docker image builds successfully" "docker build exited non-zero"
  echo "Bail out! Cannot continue without a built image."
  exit 1
fi

# ── Test 2: Required binaries exist ───────────────────────
header "Checking required binaries..."
MISSING_BINS=""
for bin in /haven/haven /usr/bin/curl /usr/bin/tor /usr/bin/bash; do
  if ! docker run --rm --entrypoint "" "$IMAGE" test -f "$bin"; then
    MISSING_BINS="$MISSING_BINS $bin"
  fi
done

if [[ -z "$MISSING_BINS" ]]; then
  pass "Required binaries exist (haven, curl, tor, bash)"
else
  fail "Required binaries exist" "missing:$MISSING_BINS"
fi

# ── Test 3: start.sh is executable ────────────────────────
header "Checking entrypoint permissions..."
if docker run --rm --entrypoint "" "$IMAGE" test -x /start.sh; then
  pass "start.sh is executable"
else
  fail "start.sh is executable"
fi

# ── Test 4: Env validation — missing all required vars ────
header "Testing env validation (missing all vars)..."
OUTPUT=$(docker run --rm --entrypoint "" "$IMAGE" \
  bash -c '/start.sh 2>&1 || true' 2>&1)

if echo "$OUTPUT" | grep -q "missing required env vars"; then
  pass "Exits with error when OWNER_NPUB and RELAY_URL are missing"
else
  fail "Exits with error when OWNER_NPUB and RELAY_URL are missing" \
    "output: $OUTPUT"
fi

# ── Test 5: Env validation — partial vars ─────────────────
header "Testing env validation (partial vars)..."
OUTPUT=$(docker run --rm --entrypoint "" \
  -e OWNER_NPUB="npub1test" \
  "$IMAGE" bash -c '/start.sh 2>&1 || true' 2>&1)

if echo "$OUTPUT" | grep -q "missing required env vars"; then
  pass "Exits with error when only OWNER_NPUB is set (RELAY_URL missing)"
else
  fail "Exits with error when only OWNER_NPUB is set (RELAY_URL missing)" \
    "output: $OUTPUT"
fi

# ── Test 6–8: Functional tests with running container ─────
header "Starting container for functional tests..."
CONTAINER="haven-test-$$"

# Create data dirs and empty relay files for isolated testing
mkdir -p "$TEST_DATA_DIR"/{blossom,db}
echo '[]' > "$TEST_DATA_DIR/relays_blastr.json"
echo '[]' > "$TEST_DATA_DIR/relays_import.json"

docker run -d \
  --name "$CONTAINER" \
  --env-file "$PROJECT_DIR/.env.test" \
  -v "$TEST_DATA_DIR/relays_blastr.json:/haven/relays_blastr.json:ro" \
  -v "$TEST_DATA_DIR/relays_import.json:/haven/relays_import.json:ro" \
  -v "$TEST_DATA_DIR/blossom:/haven/blossom" \
  -v "$TEST_DATA_DIR/db:/haven/db" \
  --health-cmd "curl -sf http://localhost:3355 || exit 1" \
  --health-interval 5s \
  --health-timeout 3s \
  --health-retries 10 \
  --health-start-period 15s \
  "$IMAGE" > /dev/null

# Wait for the container to be up (max ~60s)
echo "# Waiting for container to start..."
STARTED=false
for i in $(seq 1 30); do
  STATE=$(docker inspect --format='{{.State.Running}}' "$CONTAINER" 2>/dev/null || echo "false")
  if [[ "$STATE" != "true" ]]; then
    break  # container exited
  fi
  if docker logs "$CONTAINER" 2>&1 | grep -q "is booting up"; then
    STARTED=true
    break
  fi
  sleep 2
done

# ── Test 6: Haven process starts ──────────────────────────
if $STARTED; then
  pass "Haven process is running inside container"
else
  fail "Haven process is running inside container" \
    "container state=$STATE; logs: $(docker logs --tail 20 "$CONTAINER" 2>&1)"
fi

# ── Test 7: Port 3355 is listening ────────────────────────
header "Checking port 3355..."
PORT_OK=false
for i in $(seq 1 15); do
  if docker exec "$CONTAINER" curl -sf http://localhost:3355 &>/dev/null; then
    PORT_OK=true
    break
  fi
  sleep 2
done

if $PORT_OK; then
  pass "Port 3355 responds to HTTP requests"
else
  fail "Port 3355 responds to HTTP requests" \
    "curl failed after 30s; logs: $(docker logs --tail 10 "$CONTAINER" 2>&1)"
fi

# ── Test 8: Docker healthcheck passes ─────────────────────
header "Waiting for healthcheck..."
HEALTHY=false
for i in $(seq 1 20); do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER" 2>/dev/null || echo "unknown")
  if [[ "$STATUS" == "healthy" ]]; then
    HEALTHY=true
    break
  fi
  sleep 3
done

if $HEALTHY; then
  pass "Docker healthcheck reports healthy"
else
  fail "Docker healthcheck reports healthy" \
    "status=$STATUS; logs: $(docker logs --tail 10 "$CONTAINER" 2>&1)"
fi

# ── Test 9: Graceful shutdown ─────────────────────────────
header "Testing graceful shutdown..."
if docker stop -t 10 "$CONTAINER" > /dev/null 2>&1; then
  pass "Container shuts down gracefully on SIGTERM"
else
  fail "Container shuts down gracefully on SIGTERM" "docker stop failed or timed out"
fi

# ── Summary ───────────────────────────────────────────────
echo ""
echo "1..$TOTAL_TESTS"
echo "# passed: $PASS / $TOTAL_TESTS"
[[ $FAIL -gt 0 ]] && echo "# FAILED: $FAIL" && exit 1
echo "# All tests passed!"
exit 0
