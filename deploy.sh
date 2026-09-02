#!/usr/bin/env bash
# Deploy the static pages and verify what's actually served.
#
# The failure mode this avoids: requesting a Pages build while one is already
# in flight. GitHub errors the duplicate (duration 0ms) and the original slows
# to a crawl. Wait for idle, push once, then poll — never force.
set -euo pipefail
cd "$(dirname "$0")"
REPO=Design-Prabal/scheduling-ia
SITE=https://design-prabal.github.io/scheduling-ia

status() { gh api "repos/$REPO/pages" -q '.status' 2>/dev/null || echo unknown; }
hash_of() { python3 -c "import sys,hashlib;print(hashlib.sha256(sys.stdin.buffer.read()).hexdigest()[:12])"; }

wait_idle() {
  local label="$1" i
  for i in $(seq 1 60); do
    local s; s=$(status)
    [ "$s" != "building" ] && { echo "  $label: idle ($s)"; return 0; }
    [ $((i % 5)) -eq 0 ] && echo "  $label: still building (${i}0s)"
    sleep 10
  done
  echo "  $label: TIMED OUT after 10m" >&2; return 1
}

echo "1/4  waiting for any in-flight build"
wait_idle "queue"

echo "2/4  pushing"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -q -m "${1:-Update site}"
fi
git push -q origin main
echo "  pushed $(git rev-parse --short HEAD)"

echo "3/4  waiting for the build of this commit"
sleep 8
wait_idle "build"
gh api "repos/$REPO/pages/builds/latest" \
  -q '"  " + .status + "  " + .commit[0:7] + "  " + (.duration|tostring) + "ms"'

echo "4/4  verifying what is served"
fail=0
for page in ia-options prototype ""; do
  path="${page:+$page/}"
  local_h=$(cat "${page:-.}/index.html" | hash_of)
  remote_h=$(curl -sL "$SITE/$path?cb=$RANDOM" | hash_of)
  if [ "$local_h" = "$remote_h" ]; then
    printf "  ok    /%-12s %s\n" "$path" "$local_h"
  else
    printf "  STALE /%-12s local=%s remote=%s\n" "$path" "$local_h" "$remote_h"; fail=1
  fi
done
[ $fail -eq 0 ] && echo "done — live matches this build" || { echo "done — SOMETHING IS STALE" >&2; exit 1; }
