# PRP: Stack-neutral default template and conditional reference loading

> **Version:** 1.0
> **Created:** 2026-10-13
> **Status:** Completed
> **Issue:** [#3](https://github.com/willywg/prp-manager/issues/3) (template) and [#2](https://github.com/willywg/prp-manager/issues/2) (reference loading)

---

## Goal
The template shipped with the skill (`prp-manager/assets/templates/prp_base.md`) contains no stack-specific commands or code, and `SKILL.md` tells the agent at which workflow step to read each bundled file and how to turn the template's command placeholders into the project's real commands.

## Why
- The shipped template hardcodes Python (`ruff`, `mypy`, `uv run pytest`, `async def`, `__init__.py`). On any other stack the agent must translate all of it, and remnants leak into generated PRPs.
- If the user declines Initialize, `SKILL.md` does not say which template to use. The agent falls back to the Python template, so the PRP's validation loop fails at the first command.
- `SKILL.md` lists the bundled files under a generic "References" section. The agent may skip `references/customization.md` exactly when it writes validation commands, or load `references/examples.md` (356 lines) when it is not needed. The Agent Skills best practices ask to say *when* to load each file.
- Confirmed in practice: initializing PRPs in this repo (markdown only) required rewriting almost the whole template by hand.

## What
- Initialize on a non-Python project produces a project template with that project's real commands and no Python remnants.
- Generate without a project template still produces a PRP with real, executable validation commands.
- The agent reads `customization.md` when writing validation commands, and reads `examples.md` only when unsure about expected output.

### Success Criteria
- [x] `prp-manager/assets/templates/prp_base.md` has no Python-specific command, code or path
- [x] `SKILL.md` names the step at which each bundled file is read; no generic "see references" list remains
- [x] `SKILL.md` defines the fallback when `PRPs/templates/prp_base.md` does not exist and the user declines Initialize
- [x] `references/customization.md` explains how to resolve command placeholders, covers Go and Rust, unlisted stacks, and projects with no linter or tests
- [x] Initialize run on a Node fixture and a Go fixture yields templates with real commands and no unresolved command placeholders
- [x] `agentskills validate` passes and `metadata.version` is `"1.1"`

---

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- file: CLAUDE.md
  why: Repo rules (skill folder vs repo docs, what to keep in sync)

- file: prp-manager/SKILL.md
  why: "References" section (lines 27-31), Workflow 1 Step 3 (86-99),
       Workflow 2 Pre-check (116-118) and Step 3 (138-149) are edited

- file: prp-manager/assets/templates/prp_base.md
  why: Rewritten to be stack-neutral; keep its section structure

- file: prp-manager/references/customization.md
  why: Gains the placeholder guide and new stacks; keep its heading style

- url: https://agentskills.io/skill-creation/best-practices
  why: "Structure large skills with progressive disclosure" (say when to
       load each file) and "Provide defaults, not menus"

- url: https://agentskills.io/specification
  why: File references stay relative to the skill root, one level deep
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
        ├── examples.md
        └── customization.md
```

### Desired Structure (files to add/modify)
```bash
prp-manager/SKILL.md                        # Conditional file loading, fallback, version 1.1
prp-manager/assets/templates/prp_base.md    # Stack-neutral placeholders
prp-manager/references/customization.md     # Placeholder guide, Go, Rust, edge cases
README.md                                   # Stack Detection table: add Go and Rust rows
```
No files are added, moved or removed, so the trees in `README.md` and `CLAUDE.md` do not change.

### Known Gotchas
```yaml
# CRITICAL: Edit prp-manager/assets/templates/prp_base.md (shipped to users).
#   Do NOT edit PRPs/templates/prp_base.md (this repo's own template).
# CRITICAL: Two kinds of placeholders live in the shipped template:
#   - command placeholders ([lint command], [test command], ...) which the
#     agent must resolve when generating a project template or a PRP
#   - content placeholders ([Feature Name], [Description], ...) which stay in
#     the project template and are filled per PRP
#   The new SKILL.md text must make this distinction explicit.
# CRITICAL: ~/.agents/skills/prp-manager is a symlink to this repo's
#   prp-manager/ folder. Edits are live for every project on this machine
#   immediately, including half-finished ones. Keep SKILL.md coherent
#   between tasks.
# RULE: Keep markdown links to the three bundled files in SKILL.md so the
#   Level 1 link check still covers them.
# RULE: The skill is agent-agnostic. No Claude-only tool names in SKILL.md.
# RULE: Give one default command per stack in customization.md, with at most
#   a brief alternative ("defaults, not menus").
# SCOPE: references/examples.md is a worked FastAPI example and is labeled as
#   such. Leave it as is. Only touch it if it references the removed
#   "References" section (it does not today).
# SCOPE: The `description` field is out of scope (issue #4).
# SYNC: "Output Summary" in SKILL.md and "Example Output" in README.md show a
#   Python stack as sample output. They are examples, leave them.
```

---

## Implementation Blueprint

### Tasks (in execution order)
```yaml
Task 1: Make the shipped template stack-neutral
  - MODIFY: prp-manager/assets/templates/prp_base.md
  - PRESERVE: every section heading and their order
  - REPLACE: Python content with the neutral blocks in "Proposed Text A"
  - REMOVE: anti-pattern "Don't use sync functions in async context"

Task 2: Extend the customization guide
  - MODIFY: prp-manager/references/customization.md
  - ADD at top (after the intro line): "Resolving Command Placeholders"
  - ADD: Go and Rust sections after the Node.js ones
  - ADD: "Stack Not Listed" and "No Linter or Tests" sections
  - KEEP: existing four stack sections and "Special Rules to Include"
  - TEXT: "Proposed Text B"

Task 3: Tell the agent when to load each file
  - MODIFY: prp-manager/SKILL.md
  - REPLACE section "## References" with "## Bundled Files" (Proposed Text C1)
  - MODIFY "### Step 3: Generate Custom Template" in Workflow 1 (C2)
  - MODIFY "### Pre-check" in Workflow 2 (C3)
  - MODIFY the "Use template from" line in Workflow 2 Step 3 (C4)
  - BUMP: metadata.version "1.0" -> "1.1"
  - PRESERVE: frontmatter name/description, step numbering, three workflows

Task 4: Sync repo docs
  - MODIFY: README.md "Stack Detection" table: add rows
      | Go   | go modules | gofmt, go vet        | go test    |
      | Rust | cargo      | cargo fmt, clippy    | cargo test |
  - NO CHANGE: CLAUDE.md
```

### Proposed Text (with CRITICAL details)

**A. `assets/templates/prp_base.md` replacement blocks.** Sections not listed here stay unchanged.

````markdown
### Documentation & References
```yaml
# MUST READ - Include these in your context window
- url: [Official docs URL]
  why: [Specific sections/methods needed]

- file: [path/to/similar_feature]
  why: [Pattern to follow, gotchas to avoid]

- doc: [Library documentation URL]
  section: [Specific section about common pitfalls]
  critical: [Key insight that prevents common errors]
```

### Current Codebase Structure
```text
[Output of the project tree, 2 levels deep, limited to relevant folders]
```

### Desired Structure (files to add/modify)
```text
[path/to/new_module]/
├── [new_file]        # [Responsibility]
└── [new_file]        # [Responsibility]
[path/to/existing_file]   # MODIFY: [what changes]
```

### Known Gotchas & Library Quirks
```text
CRITICAL: [Library name] requires [specific setup]
GOTCHA: [Behavior that defies a reasonable assumption]
LIMIT: [Rate limit, size limit or version constraint]
```
````

````markdown
### Data Models
```text
[Types, schemas or tables this feature adds or changes, in the project's
language. Remove this section if the feature has none.]
```

### Tasks (in execution order)
```yaml
Task 1: [Description]
  - MODIFY: [path/to/existing_file]
  - FIND pattern: "[existing symbol or text]"
  - INJECT after: "[anchor]"
  - PRESERVE: existing public signatures

Task 2: [Description]
  - CREATE: [path/to/new_file]
  - MIRROR pattern from: [path/to/similar_file]
  - MODIFY: names and core logic
  - KEEP: error handling pattern identical

Task N: [Description]
  ...
```

### Pseudocode (with CRITICAL details)
```text
# Task 1: [Description]
function new_feature(param):
    # PATTERN: Validate input first (see [path/to/validators])
    validated = validate(param)

    # GOTCHA: [Resource] must be acquired through [existing helper]
    # CRITICAL: [External constraint, e.g. API returns 429 above 10 req/sec]
    result = call_dependency(validated)

    # PATTERN: Return the project's standard response shape
    return format_response(result)
```

### Integration Points
```yaml
DATA:
  - [Migration, schema or storage change, or "none"]

CONFIG:
  - add to: [path/to/config]
  - pattern: "[How settings are declared in this project]"

ENTRY POINTS:
  - add to: [path/to/routes, CLI, or module index]
  - pattern: "[How features are registered in this project]"
```
````

````markdown
## Validation Loop

### Level 1: Syntax & Style
```bash
# Run FIRST - fix errors before proceeding
[lint command]
[type check command]
```

### Level 2: Unit Tests
```text
Test cases to create in [path/to/tests], following [existing test file]:
- Happy path: [input] -> [expected result]
- Invalid input: [input] -> [expected error]
- Dependency failure: [timeout or error] -> [expected handling]
```

```bash
# Run and iterate until passing
[test command for the new tests]
```

### Level 3: Integration Test
```bash
# Start or build the project
[start command]

# Exercise the feature end to end
[request, CLI call or script that exercises the feature]

# Expected: [observable result]
```

---

## Final Checklist

- [x] All tests pass: `[full test command]`
- [x] No linting errors: `[lint command]`
- [x] No type errors: `[type check command]`
- [x] Manual test successful
- [x] Error cases handled gracefully
- [x] Logs are informative but not verbose
- [x] Documentation updated if needed
````

**B. `references/customization.md` additions.**

````markdown
## Resolving Command Placeholders

The default template uses these command placeholders. Replace each with the
project's real command. Never leave one unresolved and never invent a tool the
project does not use: if a level has no tool, delete that line.

| Placeholder | Where to find the real command |
|-------------|--------------------------------|
| `[lint command]` | Lint config file, `scripts` in package.json, Makefile, CI workflow |
| `[type check command]` | Type checker config, CI workflow. Delete if the language has none |
| `[test command for the new tests]` | Test config and how existing tests are run, scoped to the new files |
| `[full test command]` | The command CI runs for the whole suite |
| `[start command]` | README "getting started", `scripts`, Makefile, Procfile |

Prefer commands the project already declares (package scripts, Makefile
targets, CI steps) over calling the tool directly, so the PRP runs what CI
runs. Other bracketed text such as `[Feature Name]` is filled per PRP and
stays in the project template.
````

````markdown
### Go (go modules)

```bash
# Level 1: Syntax & Style
gofmt -l .
go vet ./...

# Level 2: Tests
go test ./...
```

### Rust (cargo)

```bash
# Level 1: Syntax & Style
cargo fmt --check
cargo clippy -- -D warnings

# Level 2: Tests
cargo test
```

## Stack Not Listed

Derive the commands from the project itself, in this order: CI workflow files,
Makefile or task runner targets, package manager scripts, then the README. If
none declares a command for a level, ask the user rather than guessing.

## No Linter or Tests

Some projects (documentation, configuration, content) have no linter or test
suite. Replace the validation levels with the checks that do exist, such as a
schema or format validator, a build command, or a link check, and make Level 2
a manual review against the success criteria. State in the template that no
automated tests exist so PRPs do not reference them.
````

**C. `SKILL.md` changes.**

C1. Replace the `## References` section with:

```markdown
## Bundled Files
Read each file at the step that names it, not up front:
- [assets/templates/prp_base.md](assets/templates/prp_base.md): stack-neutral PRP template. Read in Workflow 1 Step 3, or in Workflow 2 when the project has no template.
- [references/customization.md](references/customization.md): validation commands per stack and how to resolve the template's command placeholders. Read whenever you write validation commands.
- [references/examples.md](references/examples.md): worked example of the three workflows. Read only if you are unsure what a workflow's output should look like.

The project's own template lives at `PRPs/templates/prp_base.md` (created by Workflow 1).
```

C2. In Workflow 1 Step 3, after the `mkdir` block, replace the "Generate ... with:" list with:

```markdown
**Generate `PRPs/templates/prp_base.md`:**
1. Read [assets/templates/prp_base.md](assets/templates/prp_base.md) and keep its section structure.
2. Read [references/customization.md](references/customization.md) before writing any validation command.
3. Replace every command placeholder (`[lint command]`, `[test command ...]`, `[start command]`, ...) with the project's real command. If the project has no tool for a line, delete the line instead of inventing one.
4. Keep content placeholders such as `[Feature Name]`: they are filled per PRP.
5. Adapt the rest to the project: codebase tree format, pseudocode and data model blocks in the project's language, gotchas from AGENTS.md/CLAUDE.md/GEMINI.md, test patterns from existing tests.

The generated template must contain no unresolved command placeholders.
```

C3. In Workflow 2 Pre-check, after the quoted suggestion, add:

```markdown
If the user declines, use [assets/templates/prp_base.md](assets/templates/prp_base.md) for this PRP and resolve its command placeholders for this project following [references/customization.md](references/customization.md). Never write a PRP with unresolved command placeholders: its validation loop cannot run.
```

C4. In Workflow 2 Step 3, replace the "Use template from" line with:

```markdown
**Use template from:** `PRPs/templates/prp_base.md` (or the bundled default as described in Pre-check)
```

### Integration Points
```yaml
FRONTMATTER:
  - field: metadata.version
  - change: "1.0" -> "1.1"

DISTRIBUTION:
  - skills.sh: reads prp-manager/SKILL.md from main; no extra step
  - README install section: no change
  - Existing users: project templates already generated are not affected;
    they get the new default only on a new Initialize
```

---

## Validation Loop

### Level 1: Spec & Structure
```bash
# Run FIRST - fix errors before proceeding
uvx --from skills-ref agentskills validate ./prp-manager
# Expected: "Valid skill: prp-manager"

# SKILL.md stays under 500 lines
wc -l prp-manager/SKILL.md

# Every relative link in SKILL.md resolves (no output = OK)
grep -oE '\]\([^)#]+' prp-manager/SKILL.md | sed 's/^](//' | grep -v '^http' \
  | while read -r f; do [ -e "prp-manager/$f" ] || echo "BROKEN: $f"; done

# Shipped template has no Python remnants (no output = OK)
grep -nEi 'ruff|mypy|pytest|uv run|python|\.py|async def|__init__|fastapi|pydantic' \
  prp-manager/assets/templates/prp_base.md

# Each bundled file is referenced with a condition (expect >= 3, >= 3, >= 1)
grep -c 'assets/templates/prp_base.md' prp-manager/SKILL.md
grep -c 'references/customization.md' prp-manager/SKILL.md
grep -c 'references/examples.md' prp-manager/SKILL.md

# Version bumped
grep -n 'version:' prp-manager/SKILL.md   # Expected: version: "1.1"
```

### Level 2: Behavior Check
```yaml
# Build two throwaway fixture projects OUTSIDE this repo (scratch directory):
#   node-fixture: package.json with pnpm, scripts lint="biome check src/",
#                 test="vitest run"; biome.json; vitest.config.ts; src/index.ts
#   go-fixture:   go.mod; main.go; main_test.go
#
# In each fixture run Workflow 1 with the edited skill. Prefer a fresh agent
# session so the test does not depend on this session's context, e.g.:
#   cd <fixture> && claude -p "Initialize PRPs for this project"
# If no fresh session is available, follow SKILL.md step by step and say so
# in the report.
#
# Then check each generated PRPs/templates/prp_base.md:
```
```bash
# No unresolved command placeholders (no output = OK)
grep -nE '\[[^]]*command[^]]*\]' PRPs/templates/prp_base.md

# No Python remnants (no output = OK)
grep -nEi 'ruff|mypy|pytest|uv run|\.py\b' PRPs/templates/prp_base.md

# Real commands present
grep -nE 'pnpm|biome|vitest' PRPs/templates/prp_base.md     # node-fixture
grep -nE 'go vet|go test' PRPs/templates/prp_base.md        # go-fixture
```
```yaml
# Fallback check: in a third fixture copy (no PRPs/ folder), ask for a small
# PRP and decline initialization. The PRP must have real commands and pass
# the same two "no output" greps.
```

### Level 3: Triggering
Not applicable: `description` is unchanged.

---

## Final Checklist

- [x] `agentskills validate ./prp-manager` passes
- [x] SKILL.md under 500 lines, relative links resolve
- [x] Shipped template passes the "no Python remnants" grep
- [x] Initialize verified on Node and Go fixtures; fallback verified
- [x] No Claude-only or stack-specific assumption added to SKILL.md
- [x] README Stack Detection table updated; CLAUDE.md unchanged
- [x] `metadata.version` is `"1.1"`
- [x] Commit or PR references #2 and #3

---

## Anti-Patterns to Avoid

- ❌ Don't edit this repo's `PRPs/templates/prp_base.md` instead of the shipped one
- ❌ Don't keep a generic "see references" list next to the conditional pointers
- ❌ Don't turn `customization.md` into a menu of every tool per language
- ❌ Don't rewrite `references/examples.md`; it is a labeled example
- ❌ Don't touch the `description` field (issue #4)
- ❌ Don't skip the fixture runs because "it is only markdown"

---

## Notes

- Trade-off accepted in #3: the shipped template is less concrete as an example. `customization.md` and the worked FastAPI example in `examples.md` keep the concrete material, and `SKILL.md` now sends the agent to the first at the right moment.
- The "No Linter or Tests" section comes from initializing PRPs in this repo, which has neither.
- Follow-up candidates, not in scope: trimming `examples.md` (356 lines), and a non-Python example.
