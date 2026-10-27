# Helpers for the guide runs.
#
# capture NAME EXPECTED_EXIT_CODE <<'__CMD__' ... __CMD__
#   Runs the command from stdin in the current shell (cd and variables carry over), saves its
#   combined output to $CAP_DIR/NAME.txt and the command, exit code and time to NAME.json.
#   The guide's build refuses a capture whose recorded command differs from the command it shows.
# setup <<'__SETUP__' ... __SETUP__
#   A step the guide describes in prose (writing a file it shows, installing a package).
#   The job fails if it fails.
# finish
#   Ends a script: exits 1 if any capture had an unexpected exit code.

CAP_DIR="${CAP_DIR:-$PWD/captures}"
mkdir -p "$CAP_DIR"
CAPTURE_FAILED=0

capture() {
  local name=$1 expected=${2:-0} cmd rc started
  cmd=$(cat)
  started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  eval "$cmd" >"$CAP_DIR/$name.txt" 2>&1 </dev/null
  rc=$?
  jq -n --arg cmd "$cmd" --argjson rc "$rc" --arg at "$started" --arg run_id "${GITHUB_RUN_ID:-local}" \
    '{cmd: $cmd, rc: $rc, at: $at, run_id: $run_id}' >"$CAP_DIR/$name.json"
  printf '::group::%s (exit %s)\n$ %s\n' "$name" "$rc" "$cmd"
  cat "$CAP_DIR/$name.txt"
  echo '::endgroup::'
  if [ "$rc" -ne "$expected" ]; then
    echo "::error::capture $name exited $rc, expected $expected"
    CAPTURE_FAILED=1
  fi
}

setup() {
  local body
  body=$(cat)
  echo "::group::setup"
  echo "$body"
  echo "::endgroup::"
  if ! eval "$body" </dev/null; then
    echo "::error::setup step failed"
    exit 1
  fi
}

finish() {
  exit "$CAPTURE_FAILED"
}
