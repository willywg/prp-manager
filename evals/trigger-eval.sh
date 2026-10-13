#!/bin/bash
# Measures how often the skill is triggered for each labeled query.
# Usage: evals/trigger-eval.sh <queries.json> [runs]
# Output: JSON array with trigger_rate and pass per query, then a summary.
# Runs in a temporary neutral project so this repo's files do not bias results.

QUERIES_FILE="${1:?Usage: $0 <queries.json> [runs]}"
RUNS="${2:-3}"
SKILL_NAME="prp-manager"
THRESHOLD="0.5"
MAX_TURNS="${MAX_TURNS:-1}"

QUERIES_FILE="$(cd "$(dirname "$QUERIES_FILE")" && pwd)/$(basename "$QUERIES_FILE")"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
printf '# demo-app\n\nSmall web API with a reports page and user accounts.\n' > "$WORKDIR/README.md"
cd "$WORKDIR" || exit 1

# Returns 0 if the skill was invoked. claude exits non-zero at --max-turns,
# so its exit code is ignored on purpose.
check_triggered() {
  { claude -p "$1" --output-format stream-json --verbose --max-turns "$MAX_TURNS" 2>/dev/null || true; } \
    | jq -e -s --arg s "$SKILL_NAME" \
      'any(.[]; .type == "assistant" and any(.message.content[]?; .type == "tool_use" and .name == "Skill" and .input.skill == $s))' \
      > /dev/null 2>&1
}

count=$(jq length "$QUERIES_FILE")
results=$(
  for i in $(seq 0 $((count - 1))); do
    query=$(jq -r ".[$i].query" "$QUERIES_FILE")
    should=$(jq -r ".[$i].should_trigger" "$QUERIES_FILE")
    hits=0
    for _ in $(seq 1 "$RUNS"); do
      check_triggered "$query" && hits=$((hits + 1))
    done
    jq -n --arg query "$query" --argjson should "$should" --argjson hits "$hits" \
      --argjson runs "$RUNS" --argjson t "$THRESHOLD" \
      '{query: $query, should_trigger: $should, triggers: $hits, runs: $runs,
        trigger_rate: ($hits / $runs),
        pass: (if $should then ($hits / $runs) > $t else ($hits / $runs) < $t end)}'
  done | jq -s '.'
)

echo "$results"
echo "$results" | jq -r '"SUMMARY: \(map(select(.pass)) | length)/\(length) passed"' >&2
