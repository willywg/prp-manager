# PRP: [Feature Name]

> **Version:** 1.0
> **Created:** [Date]
> **Status:** Draft | Ready | In Progress | Completed
> **Issue:** [GitHub issue number/URL, if any]

---

## Goal
[What changes in the skill or repo docs - be specific about the end state]

## Why
- [What goes wrong for agents or users today]
- [Which Agent Skills guidance or user feedback motivates it]
- [Who benefits: skill users, contributors, a specific agent]

## What
[Observable behavior of the skill after the change: when it triggers, what the agent reads, what it outputs]

### Success Criteria
- [ ] [Specific observable outcome 1]
- [ ] [Specific observable outcome 2]
- [ ] `agentskills validate` passes

---

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- file: CLAUDE.md
  why: Repo rules (skill folder vs repo docs, what to keep in sync)

- file: prp-manager/SKILL.md
  why: Frontmatter and the three workflows; most changes land here

- url: https://agentskills.io/specification
  why: Frontmatter fields and limits, progressive disclosure, file references

- url: https://agentskills.io/skill-creation/best-practices
  why: [Specific section that applies to this change]

- file: [prp-manager/references/... or assets/...]
  why: [Pattern to follow or content affected]
```

### Current Structure
```bash
prp-manager/                  # Repository root (docs, not installed)
├── README.md                 # Installation and usage documentation
├── LICENSE
├── CLAUDE.md                 # Guidance for agents working on this repo
├── PRPs/                     # PRPs for this repo (not part of the skill)
│   └── templates/prp_base.md
└── prp-manager/              # THE SKILL (the only folder users install)
    ├── SKILL.md              # Frontmatter + workflows
    ├── assets/templates/prp_base.md   # Default PRP template shipped to users
    └── references/
        ├── examples.md       # Usage examples for the three workflows
        └── customization.md  # Stack-specific validation commands
```

### Desired Structure (files to add/modify)
```bash
# List only the files this PRP touches, with a comment on what changes
prp-manager/SKILL.md          # [what changes]
```

### Known Gotchas
```yaml
# CRITICAL: Only prp-manager/ is the skill. README.md, LICENSE, CLAUDE.md and
#   PRPs/ are repo files and must never be required by the skill at runtime.
# CRITICAL: This file (PRPs/templates/prp_base.md) is this repo's own template.
#   The template shipped to users is prp-manager/assets/templates/prp_base.md.
#   Do not confuse them.
# CRITICAL: Frontmatter `name` must stay `prp-manager` and match the directory
#   name. Changing it breaks installs and the skills.sh listing.
# LIMIT: `description` max 1024 characters, `compatibility` max 500.
# LIMIT: Keep SKILL.md under 500 lines; move detail to references/.
# RULE: File references use relative paths from the skill root and stay one
#   level deep from SKILL.md (no reference file pointing to another).
# RULE: The skill is agent-agnostic. Do not add Claude-only instructions or
#   tool names to SKILL.md.
# RULE: There is no code, linter or test suite in this repo. Validation is the
#   spec validator plus a manual run of the affected workflow.
# SYNC: The repository tree appears in README.md and CLAUDE.md. Update both if
#   files inside prp-manager/ are added, moved or removed.
# SYNC: Example output blocks are duplicated in SKILL.md ("Output Summary"),
#   README.md ("Example Output") and references/examples.md.
# VERSION: Bump `metadata.version` in SKILL.md when skill behavior changes.
```

---

## Implementation Blueprint

### Tasks (in execution order)
```yaml
Task 1: [Description]
  - MODIFY: prp-manager/SKILL.md
  - FIND section: "## Workflow N: ..."
  - CHANGE: [what to add/replace]
  - PRESERVE: step numbering and the three-workflow structure

Task 2: [Description]
  - MODIFY: prp-manager/references/[file].md
  - MIRROR style from: [existing section]

Task N: Sync repo docs
  - MODIFY: README.md and CLAUDE.md only if structure, install steps or
    documented behavior changed
  - BUMP: metadata.version in prp-manager/SKILL.md
```

### Proposed Text (with CRITICAL details)
```markdown
<!-- Write the exact wording for new or changed instructions here.
     Skill instructions are the product: draft them in the PRP, not during
     execution. Note the reason behind each non-obvious instruction. -->
```

### Integration Points
```yaml
FRONTMATTER:
  - field: [name | description | license | compatibility | metadata]
  - change: [new value, or "none"]

DISTRIBUTION:
  - skills.sh: reads prp-manager/SKILL.md from main; no extra step
  - README install section: [update needed? yes/no]
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
```

### Level 2: Behavior Check
```yaml
# Run the affected workflow with the edited skill and compare with the
# expected behavior. State which project was used.
Initialize: run it in a project of a relevant stack; check the generated
  PRPs/templates/prp_base.md uses that project's real commands
Generate:   ask for a small PRP; check naming (NNN--kebab-case), context
  and executable validation gates
Execute:    run a small PRP end to end; check validation loop is followed
```

### Level 3: Triggering (only if `description` changed)
```yaml
# Write ~20 realistic queries: half should trigger, half near-misses that
# should not. Run each a few times and record the trigger rate.
# See https://agentskills.io/skill-creation/optimizing-descriptions
```

---

## Final Checklist

- [ ] `agentskills validate ./prp-manager` passes
- [ ] SKILL.md under 500 lines, relative links resolve
- [ ] Affected workflow run manually and behaves as described
- [ ] No Claude-only or stack-specific assumption added to SKILL.md
- [ ] README.md and CLAUDE.md in sync (tree, install steps, examples)
- [ ] `metadata.version` bumped if behavior changed
- [ ] Linked issue referenced in the commit or PR

---

## Anti-Patterns to Avoid

- ❌ Don't put skill content in root files, or repo docs inside `prp-manager/`
- ❌ Don't explain what agents already know; add only what they would get wrong
- ❌ Don't list several equal options; give a default and a brief alternative
- ❌ Don't add a reference file without saying in SKILL.md when to read it
- ❌ Don't grow the `description` with keywords from single failed queries
- ❌ Don't skip the behavior check because "it is only markdown"

---

## Notes

[Additional context, decisions made, or future considerations]
