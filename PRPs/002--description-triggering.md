# PRP: Rewrite the skill description and validate triggering with test queries

> **Version:** 1.0
> **Created:** 2026-10-13
> **Status:** Completed
> **Issue:** [#4](https://github.com/willywg/prp-manager/issues/4)

---

## Goal
The `description` in `prp-manager/SKILL.md` triggers the skill when a user wants to plan, spec or execute a feature for an AI agent even without saying "PRP", does not trigger on near-miss requests, and that claim is backed by a measured trigger eval kept in the repo.

## Why
- The current description (354 characters) lists literal keywords: "PRP", "feature planning", "implementation blueprint", "context engineering". Users who do not know the term will not write them, so the skill may stay unused exactly for the new users arriving from skills.sh.
- The Agent Skills guide on optimizing descriptions recommends imperative phrasing, user intent over mechanics, and covering cases where the domain is not named.
- A broader description can over-trigger on trivial or unrelated planning requests. Without measurement there is no way to know whether a rewrite helped or hurt.

## What
- A trigger eval exists in `evals/` (repo level, not part of the skill): labeled queries split into train and validation sets, and a script that reports the trigger rate per query.
- The current description is measured first (baseline).
- A new description is adopted only if it beats the baseline on the validation set without new false triggers. Otherwise the current one stays and the issue is closed with the data.

### Success Criteria
- [x] `evals/trigger-eval.sh` runs a query file and outputs per-query trigger rates as JSON
- [x] 20 labeled queries exist, split 12 train / 8 validation, each set mixing should-trigger and should-not-trigger
- [x] Baseline and final results are recorded in this PRP's Notes (pass counts for train and validation)
- [x] Final description is under 1024 characters, written in imperative form, and has a validation pass rate greater than or equal to the baseline with no should-not-trigger query failing
- [x] `agentskills validate` passes; `metadata.version` is `"1.2"` if the description changed

---

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- file: CLAUDE.md
  why: Repo rules (skill folder vs repo docs, what to keep in sync)

- file: prp-manager/SKILL.md
  why: Only the `description` line in the frontmatter (line 3) changes

- url: https://agentskills.io/skill-creation/optimizing-descriptions
  why: Writing principles, query design (near-misses), train/validation
       split, the optimization loop and when to stop

- url: https://agentskills.io/specification
  why: description limit is 1024 characters
```

### Current Structure
```bash
prp-manager/                  # Repository root (docs, not installed)
├── README.md
├── CLAUDE.md
├── PRPs/                     # PRPs for this repo (not part of the skill)
└── prp-manager/              # THE SKILL
    ├── SKILL.md
    ├── assets/templates/prp_base.md
    └── references/
```

### Desired Structure (files to add/modify)
```bash
evals/                          # NEW, repo level, not part of the skill
├── README.md                   # How to run the eval and read results
├── trigger-eval.sh             # Runs queries, reports trigger rates
├── queries.train.json          # 12 labeled queries
└── queries.validation.json     # 8 labeled queries
prp-manager/SKILL.md            # description (only if the candidate wins), version
CLAUDE.md                       # Add evals/ to the tree and the "not part of the skill" note
```

### Known Gotchas
```yaml
# CRITICAL: ~/.agents/skills/prp-manager is a symlink to this repo's
#   prp-manager/ folder. Editing the description in SKILL.md changes what
#   every new agent session on this machine sees. That is how candidates are
#   tested, and also why SKILL.md must hold a valid description at all times.
# CRITICAL: Never run the eval from inside this repo. Its CLAUDE.md and PRPs/
#   folder talk about PRPs and bias every query toward triggering. The script
#   runs in a temporary neutral project directory.
# CRITICAL: `claude -p` exits non-zero when it hits --max-turns. Do not let
#   that abort the script (no `set -e`/pipefail around the call).
# VERIFIED: with `--output-format stream-json --verbose`, a triggered skill
#   appears as an assistant message containing a tool_use with
#   name == "Skill" and input.skill == "prp-manager". The jq filter in the
#   script below was checked against real output.
# UNVERIFIED: `--max-turns 1` is assumed to still emit the first assistant
#   message with the Skill tool_use. Task 2 confirms it; use 2 if it does not.
# USAGE: this machine runs Claude Code on a claude.ai subscription, so runs
#   are not billed, but each one is a fresh session with a large context
#   (about 109 skills installed) and counts against the plan's usage limit.
#   A full pass is 20 queries x 3 runs = 60 runs. Run in batches: baseline
#   first, check how much usage it took, then decide on each candidate.
#   If the usage limit is hit mid-pass, discard that pass and rerun it later;
#   do not mix partial results. Report the number of runs per pass.
# CONTEXT: results depend on the other skills installed. On this machine
#   `scrum-story-creator` competes for "user stories" and the built-in plan
#   mode competes for "plan" requests. Record this in the results; do not
#   uninstall anything to improve the numbers.
# CONTEXT: agent clients cap the total size of skill listings and may truncate
#   long descriptions. Put what the skill does and when to use it in the first
#   two sentences, and keep the description well under the 1024 limit
#   (target: 400 to 700 characters).
# RULE: Only train-set failures may guide rewrites. Do not look at which
#   validation queries failed when revising; use validation only to compare
#   candidates.
# RULE: Do not add keywords lifted from a failed query. Generalize to the
#   category it represents.
# RULE: The description must stay agent-agnostic and in English.
# SYNC: README.md line 3 and CLAUDE.md "Project Overview" paraphrase the
#   skill's purpose. They do not need to match the description word for word.
# SCOPE: SKILL.md body, template and references are out of scope.
```

---

## Implementation Blueprint

### Tasks (in execution order)
```yaml
Task 1: Create the eval files
  - CREATE: evals/queries.train.json, evals/queries.validation.json
      (content in "Proposed Text A")
  - CREATE: evals/trigger-eval.sh (content in "Proposed Text B"), chmod +x
  - CREATE: evals/README.md: purpose, usage, how to read the output, the
      three CRITICAL/CONTEXT notes about neutral directory, cost and
      dependence on installed skills. Keep it under 40 lines.

Task 2: Smoke test the script
  - RUN: the script on a 2-query file (one obvious positive, one obvious
      negative) with 1 run each
  - CONFIRM: --max-turns 1 detects the positive; if not, change to 2
  - CONFIRM: output is valid JSON with trigger_rate and pass fields

Task 3: Measure the baseline
  - RUN: train and validation sets, 3 runs each, with the CURRENT description
  - RECORD: per-query trigger rates and pass counts in Notes

Task 4: Evaluate candidate A
  - MODIFY: prp-manager/SKILL.md description -> "Proposed Text C"
  - VERIFY: length < 1024 and `agentskills validate` passes
  - RUN: train and validation sets, 3 runs each
  - RECORD: results in Notes

Task 5: Iterate if needed (max 3 candidates in total)
  - IF train failures remain: revise from train failures only, re-run both
      sets, record. Stop when train passes or there is no improvement.
  - IF stuck: try a structurally different framing instead of small tweaks.

Task 6: Decide
  - SELECT: the description with the best validation pass rate (it may be
      the baseline, or an earlier candidate)
  - ADOPT a candidate only if validation pass rate >= baseline AND no
      should-not-trigger query fails on either set
  - IF the baseline wins: restore the original description exactly, do not
      bump the version, and state it in Notes
  - IF a candidate wins: leave it in SKILL.md, bump metadata.version to "1.2"

Task 7: Sync repo docs
  - MODIFY: CLAUDE.md tree and the "not part of the skill" sentence to
      include evals/
  - NO CHANGE: README.md (unless the adopted description contradicts line 3)
```

### Proposed Text (with CRITICAL details)

**A. Query sets.** Labels are fixed; do not relabel a query to make it pass. Positives vary in explicitness and language; negatives are near-misses that share vocabulary with the skill.

`evals/queries.train.json`
```json
[
  { "query": "Create a PRP for adding Google OAuth login", "should_trigger": true },
  { "query": "before you write any code, plan out how we'd add CSV export to the reports page. i want a doc another agent can implement from", "should_trigger": true },
  { "query": "I need an implementation blueprint for migrating our auth from sessions to JWT, with the files to touch and how to verify each step", "should_trigger": true },
  { "query": "quiero planificar la feature de pagos con Stripe antes de implementarla, con contexto del codigo y pasos de validacion", "should_trigger": true },
  { "query": "my teammate left this file PRPs/007--rate-limiting.md, can you implement what it says and run the checks", "should_trigger": true },
  { "query": "set up the context engineering workflow for this project so we can plan features properly", "should_trigger": true },
  { "query": "write a PRD for the mobile app redesign to share with stakeholders next week", "should_trigger": false },
  { "query": "break the checkout epic into user stories for Linear", "should_trigger": false },
  { "query": "add a null check to getUser in src/users.ts", "should_trigger": false },
  { "query": "summarize the changes in PR #42 for the changelog", "should_trigger": false },
  { "query": "write a prompt for our support chatbot so it answers in a friendly tone", "should_trigger": false },
  { "query": "how does the auth middleware work in this codebase?", "should_trigger": false }
]
```

`evals/queries.validation.json`
```json
[
  { "query": "initialize prps in this repo", "should_trigger": true },
  { "query": "execute PRPs/003--csv-export.md", "should_trigger": true },
  { "query": "write a spec for the notifications feature that I can hand to an agent tomorrow to build in one go", "should_trigger": true },
  { "query": "we're adding multi-tenant support next sprint. research the codebase and put together a detailed plan with tasks in order and test commands, save it as a markdown file", "should_trigger": true },
  { "query": "plan my week: I have 3 PRs to review and a release on Thursday", "should_trigger": false },
  { "query": "draw up a product roadmap for Q1 with our top 5 initiatives", "should_trigger": false },
  { "query": "refactor utils.js to use async/await", "should_trigger": false },
  { "query": "genera la documentacion del README para este proyecto", "should_trigger": false }
]
```

**B. `evals/trigger-eval.sh`**

```bash
#!/bin/bash
# Measures how often the skill is triggered for each labeled query.
# Usage: evals/trigger-eval.sh <queries.json> [runs]
# Output: JSON array with trigger_rate and pass per query, then a summary.
# Runs in a temporary neutral project so this repo's files do not bias results.

QUERIES_FILE="${1:?Usage: $0 <queries.json> [runs]}"
RUNS="${2:-3}"
SKILL_NAME="prp-manager"
THRESHOLD="0.5"
MAX_TURNS="1"

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
```

Run the two sets in parallel (two background processes) to halve wall time. Do not parallelize inside the script.

**C. Candidate A description** (about 560 characters)

```yaml
description: Plan and implement features with PRPs (Product Requirements Prompts), implementation blueprints that give an AI coding agent the requirements, codebase context and validation steps to build a feature in one pass. Use this skill when the user wants to plan, spec or scope a feature before coding it, asks for an implementation plan or blueprint an agent can execute, wants to set up PRPs in a project, or asks to execute an existing PRP file, even if they do not say "PRP". Not for one-step code changes, PRDs for stakeholders, user stories or roadmaps.
```

Reasoning behind it, to keep in mind when revising:
- The first sentence says what a PRP is, because the term is unknown to new users and to the agent.
- "Use this skill when..." lists intents (plan, spec, scope, execute) rather than keywords.
- "even if they do not say PRP" covers the implicit cases.
- The last sentence draws the boundary against the near-misses in the query sets. If positives fail because of it, soften that sentence first.

### Integration Points
```yaml
FRONTMATTER:
  - field: description
  - change: candidate with the best validation pass rate, or unchanged
  - field: metadata.version
  - change: "1.1" -> "1.2" only if the description changed

DISTRIBUTION:
  - skills.sh: reads prp-manager/SKILL.md from main; the listing text
    updates on its own
  - README install section: no change
```

---

## Validation Loop

### Level 1: Spec & Structure
```bash
# Run FIRST - fix errors before proceeding
uvx --from skills-ref agentskills validate ./prp-manager
# Expected: "Valid skill: prp-manager"

# Description length (expected: under 1024, target 400 to 700)
awk '/^description:/{print length($0)-13}' prp-manager/SKILL.md

# Query files are valid and correctly sized (expected: 12 and 8)
jq length evals/queries.train.json evals/queries.validation.json

# Each set mixes labels (expected: both true and false present in each)
jq -c 'group_by(.should_trigger) | map({label: .[0].should_trigger, n: length})' \
  evals/queries.train.json evals/queries.validation.json

# Script syntax
bash -n evals/trigger-eval.sh

# Nothing else in the skill changed (expected: only the description and
# version lines, or no diff if the baseline won)
git diff --stat -- prp-manager/
git diff -- prp-manager/SKILL.md
```

### Level 2: Behavior Check
```yaml
# Not a workflow change, so no Initialize/Generate/Execute run is needed.
# Sanity check only: in a neutral directory, one fresh session with an
# explicit request ("Create a PRP for X") still loads the skill and follows
# Workflow 2 as before.
```

### Level 3: Triggering
```bash
# Baseline (current description), then each candidate
evals/trigger-eval.sh evals/queries.train.json 3 > "$SCRATCH"/train.<label>.json
evals/trigger-eval.sh evals/queries.validation.json 3 > "$SCRATCH"/validation.<label>.json
```
```yaml
# Write result files to a scratch directory, not into the repo.
# Acceptance:
#   - adopted description: validation pass rate >= baseline
#   - adopted description: every should_trigger=false query passes on both sets
#   - results table for baseline and each candidate recorded in Notes
# If results for a query flip between passes with the same description, raise
# runs to 5 for that query before drawing a conclusion.
```

---

## Final Checklist

- [x] `agentskills validate ./prp-manager` passes
- [x] Description under 1024 characters, imperative, agent-agnostic, in English
- [x] Baseline and all candidate results recorded in Notes
- [x] Decision follows the acceptance rule (candidate adopted or baseline kept)
- [x] Only the frontmatter of SKILL.md changed inside `prp-manager/`
- [x] `evals/` documented in `evals/README.md` and in CLAUDE.md
- [x] `metadata.version` bumped to `"1.2"` only if the description changed
- [x] No result files or temp directories left in the repo
- [x] Commit or PR references #4

---

## Anti-Patterns to Avoid

- ❌ Don't adopt the candidate because it reads better; adopt it on the numbers
- ❌ Don't tune against validation failures or relabel queries to pass
- ❌ Don't stuff keywords from failed queries into the description
- ❌ Don't run the eval inside this repo
- ❌ Don't put `evals/` inside `prp-manager/`: it is not part of the skill
- ❌ Don't leave a losing candidate in SKILL.md after the eval

---

## Notes

- 20 queries at 3 runs is a small sample. Treat a difference of one query as noise unless it repeats at 5 runs.
- Results are specific to Claude Code and to the skills installed on this machine. Other agents match descriptions differently; the eval shows direction, not a guarantee.
- If the baseline already passes everything, that is a valid outcome: keep the current description, keep the eval in the repo for future changes, and close #4 with the data.

### Results
Setup: Claude Code on this machine (about 109 skills installed), `--max-turns 1`, 3 runs per query, neutral temporary project. `--max-turns 1` was confirmed to detect triggering in the smoke test.

**Baseline (description of v1.1, 354 characters), 2026-10-13, 60 runs**

| Set | Passed | Failures (trigger rate) |
|-----|--------|-------------------------|
| Train | 11/12 | "before you write any code, plan out how we'd add CSV export..." (0/3) |
| Validation | 5/8 | "execute PRPs/003--csv-export.md" (0/3), "write a spec for the notifications feature..." (0/3), "we're adding multi-tenant support next sprint..." (0/3) |

- All 10 should-not-trigger queries passed with 0/3 on both sets: the baseline does not over-trigger.
- Every failure is a should-trigger query at 0/3, and results were all 0/3 or 3/3, so there is no borderline query at this sample size.
- Possible measurement artifact on "execute PRPs/003--csv-export.md": the file does not exist in the neutral project, so the agent's single turn may go to looking for it before loading the skill. The similar train query ("my teammate left this file PRPs/007--rate-limiting.md...") did trigger 3/3, so this is unconfirmed.

**Baseline, second pass, 60 runs.** Unplanned: the edit that should have applied candidate A failed silently, so this pass measured the baseline again.

| Set | Passed | Failures (trigger rate) |
|-----|--------|-------------------------|
| Train | 10/12 | "before you write any code, plan out..." (0/3), "my teammate left this file PRPs/007--rate-limiting.md..." (0/3) |
| Validation | 6/8 | "write a spec for the notifications feature..." (0/3), "we're adding multi-tenant support next sprint..." (0/3) |

- The two queries that name a PRP file flipped between passes (one each way). The noise floor between passes is therefore about 2 of 20 queries, even though runs within a pass agreed.
- Three queries failed in both baseline passes: "before you write any code...", "write a spec...", "we're adding multi-tenant support...".

**Candidate A (552 characters), 60 runs**

| Set | Passed | Failures (trigger rate) |
|-----|--------|-------------------------|
| Train | 11/12 | "before you write any code, plan out..." (0/3) |
| Validation | 7/8 | "we're adding multi-tenant support next sprint..." (0/3) |

- All 10 should-not-trigger queries passed with 0/3.
- "write a spec for the notifications feature..." went from 0/3 in both baseline passes to 3/3. This is the one gain above the noise floor.
- Both PRP-file queries passed; given the baseline flips, that is not evidence of improvement.

**Recheck of the two remaining failures with `MAX_TURNS=4`, candidate A, 6 runs**

- "before you write any code, plan out...": 3/3. With one turn the agent's first action is something else (in one traced run it tried a documents connector because the query says "a doc"), so the one-turn failure is mostly a measurement limit. One extra traced run at 4 turns did not load the skill, so it is not fully reliable either.
- "we're adding multi-tenant support next sprint...": 0/3. A real miss: the request reads as generic planning and never mentions a feature spec or an agent.

**Decision: candidate A adopted, version 1.2.** Validation 7/8 against 5/8 and 6/8 for the baseline, with no should-not-trigger failure. No second candidate was tried: the only train failure passes at 4 turns, and the remaining miss is a validation query, which must not guide rewrites.

Total: 186 eval sessions plus 3 for smoke test and tracing.

Follow-ups, not done: `MAX_TURNS` was made configurable in the script after these passes; a future pass at 2 or more turns would remove the first-action artifact at a higher usage cost.
