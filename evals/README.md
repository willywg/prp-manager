# Trigger eval

Measures whether the skill's `description` makes an agent load the skill for the right requests. This folder is repo tooling and is not part of the skill.

## Files

- `queries.train.json`: 12 labeled queries used to guide description changes
- `queries.validation.json`: 8 labeled queries used only to compare descriptions
- `trigger-eval.sh`: runs each query in fresh Claude Code sessions and reports the trigger rate

## Usage

Requires `claude` (Claude Code CLI) and `jq`, with the skill installed from this working copy (for example a symlink from the user skills directory to `prp-manager/`).

```bash
evals/trigger-eval.sh evals/queries.train.json 3 > train.json
evals/trigger-eval.sh evals/queries.validation.json 3 > validation.json
```

The second argument is the number of runs per query (default 3). A query passes when its trigger rate is above 0.5 if it should trigger, or below 0.5 if it should not. The summary line goes to stderr.

Set `MAX_TURNS` to give the agent more turns per run (default 1):

```bash
MAX_TURNS=4 evals/trigger-eval.sh evals/queries.train.json 3
```

## Reading results

- The script runs in a temporary neutral project. Do not run queries from inside this repo: its files mention PRPs and bias every query toward triggering.
- With one turn, a query fails if the agent's first action is something else (exploring files, another tool), even when it would load the skill a turn later. Recheck should-trigger failures with `MAX_TURNS=4` before concluding the description is at fault.
- Results vary between passes. Two passes with the same description differed on 2 of 20 queries, so treat a difference of one or two queries as noise unless it repeats.
- Each run is a full agent session and counts against the plan's usage limit. A pass over both sets at 3 runs is 60 sessions.
- Results depend on the other skills and tools installed on the machine, which compete for the same requests.
- With `MAX_TURNS` above 1 the agent may start doing the task. File writes land in the temporary project, which is deleted on exit.

## Changing the description

Measure the current description first, then the candidate. Use only train failures to guide rewrites, and adopt a candidate only if its validation pass rate is at least the baseline's and no should-not-trigger query fails. See `PRPs/002--description-triggering.md` for the full method and past results.
