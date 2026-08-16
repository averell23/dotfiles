#!/usr/bin/env bash
# Look up library documentation via the Context7 API.
#
# Usage:
#   context7.sh <libraryId> <query> [--txt] [--fast]
#
# Auth is read from $CONTEXT7_API_KEY (ctx7sk...). Calls without a key
# still work but rate-limit fast.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $(basename "$0") <libraryId> <query> [--txt] [--fast]" >&2
  exit 2
fi

LIBRARY_ID="$1"; shift
QUERY="$1"; shift

TYPE="json"
FAST="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --txt) TYPE="txt"; shift ;;
    --fast) FAST="true"; shift ;;
    -h|--help)
      sed -n '2,9p' "$0"; exit 0 ;;
    *)
      echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for URL-encoding and response pretty-printing." >&2
  exit 1
fi

LIB=$(printf %s "$LIBRARY_ID" | jq -sRr @uri)
Q=$(printf   %s "$QUERY"        | jq -sRr @uri)

URL="https://context7.com/api/v2/context?libraryId=$LIB&query=$Q&type=$TYPE&fast=$FAST"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

status=$(curl -sS -G \
  --data-urlencode "libraryId=$LIBRARY_ID" \
  --data-urlencode "query=$QUERY" \
  --data-urlencode "type=$TYPE" \
  --data-urlencode "fast=$FAST" \
  -H "Authorization: Bearer ${CONTEXT7_API_KEY:-}" \
  -o "$tmp" -w '%{http_code}' \
  "$URL" )

# `curl --data-urlencode` with -G rebuilds the querystring, so the $URL variable
# above is only kept for readability / debugging.

case "$status" in
  200)
    if [[ "$TYPE" == "json" ]]; then
      jq '.' "$tmp"
    else
      cat "$tmp"
    fi
    ;;
  202|301|4*|5*)
    cat "$tmp" >&2
    echo "HTTP $status" >&2
    exit 1
    ;;
esac
