# PRP: Distribute the Skill as a Claude Code Plugin

> **Version:** 1.0
> **Created:** 2026-10-13
> **Status:** In Progress
> **Issue:** https://github.com/willywg/prp-manager/issues/5

---

## Goal
Make this repository a Claude Code plugin marketplace with one plugin, `prp-manager`, that exposes the existing skill folder unchanged. `npx skills add` stays the primary, cross-agent install method.

## Why
- Native install and update in Claude Code (`claude plugin install`, `claude plugin update`, the `/plugin` panel)
- Teams can enable it per project through `.claude/settings.json`
- Prerequisite for submitting to Anthropic's plugin directory

## What
A user runs `claude plugin marketplace add willywg/prp-manager` and `claude plugin install prp-manager@prp-manager`, and gets the skill as `/prp-manager:prp-manager` with the same description-based activation.

### Success Criteria
- [x] `claude plugin validate --strict .` passes with no warnings or advice
- [x] Local install lists `Skills (1)  prp-manager`
- [x] `prp-manager/` has no new files; `agentskills validate` still passes
- [x] README documents the plugin install and the duplicate-listing caveat
- [x] Install from GitHub (`willywg/prp-manager`) works after push
- [x] Namespaced invocation `/prp-manager:prp-manager` checked in a session
- [ ] Submitted to the official plugin directory

---

## All Needed Context

### Documentation & References
```yaml
- url: https://code.claude.com/docs/en/plugin-marketplaces
  why: Walkthrough: marketplace.json, validate, add, install
- url: https://code.claude.com/docs/en/plugins/marketplace-reference
  why: Entry fields, strict mode, relative-path sources, reserved names
- url: https://code.claude.com/docs/en/plugins/loading
  why: How the version is computed and what gets copied to the cache
- file: CLAUDE.md
  why: Skill folder vs repo files
```

### Desired Structure (files to add/modify)
```bash
.claude-plugin/marketplace.json   # NEW: marketplace with one entry
README.md                         # "Claude Code (Plugin)" install section, tree
CLAUDE.md                         # tree, rule about the manifest
```

### Known Gotchas
```yaml
# CRITICAL: No plugin.json. With no plugin.json the marketplace entry is the
#   manifest, so nothing is added inside prp-manager/ and `npx skills` users
#   do not receive plugin files.
# CRITICAL: Marketplace name and plugin entry name are install ids
#   (prp-manager@prp-manager). Treat both as immutable once pushed.
# RULE: No `version` in the entry. The version then comes from the commit SHA,
#   so every push is an update and there is no second version to maintain
#   next to `metadata.version` in SKILL.md.
# RULE: A relative source resolves from the marketplace root (the repo root),
#   must start with "./" and cannot contain "..".
# NOTE: A marketplace added from a local path loads the plugin in place. Only
#   an install from GitHub exercises the copy into the plugin cache.
```

---

## Implementation Blueprint

### Tasks (in execution order)
```yaml
Task 1: Decide the entry layout
  - TEST in a scratch copy, both validated and installed:
      A) "source": "./",            "skills": ["./prp-manager"]
      B) "source": "./prp-manager", "skills": ["./"]
  - CHOOSE B: only the skill folder is the plugin root, so README, PRPs/ and
    evals/ are not copied into users' plugin caches. A is the layout used by
    anthropics/skills and is the fallback if B fails from GitHub.

Task 2: Add .claude-plugin/marketplace.json
  - name "prp-manager", owner, description
  - one entry: name "prp-manager", source "./prp-manager", strict false,
    skills ["./"], description, author, homepage, repository, license,
    keywords, category

Task 3: Sync repo docs
  - README.md: "Claude Code (Plugin)" section before the manual one, tree
  - CLAUDE.md: tree, manifest rule

Task 4: Verify from GitHub (after push)
  - claude plugin marketplace add willywg/prp-manager
  - claude plugin install prp-manager@prp-manager
  - claude plugin details prp-manager@prp-manager   # Skills (1) prp-manager
  - In a session: /prp-manager:prp-manager
  - If the skill is missing, switch to layout A and repeat

Task 5: Submit to the official directory
  - https://clau.de/plugin-directory-submission
```

### Integration Points
```yaml
FRONTMATTER:
  - change: none (skill behavior unchanged, no version bump)

DISTRIBUTION:
  - skills.sh: unaffected
  - README install section: updated
```

---

## Validation Loop

### Level 1: Spec & Structure
```bash
claude plugin validate --strict .
# Expected: "✔ Validation passed" with no warnings or advice

uvx --from skills-ref agentskills validate ./prp-manager
# Expected: "Valid skill: prp-manager"
```

### Level 2: Behavior Check
```bash
claude plugin marketplace add ./
claude plugin install prp-manager@prp-manager
claude plugin details prp-manager@prp-manager   # Skills (1)  prp-manager
claude plugin marketplace remove prp-manager    # clean up the local test
```

---

## Notes

Results on 2026-10-13 (Claude Code 2.1.296):

- Layouts A and B both validated and installed from a scratch copy, each listing `Skills (1)  prp-manager`.
- Final manifest: `claude plugin validate --strict .` passed. Before the README change it printed one advice line asking for a marketplace install line in the README; after the change it prints none.
- Local install from the repo root: `Skills (1)  prp-manager`, version `06686f638f73` (the commit SHA, as expected with no `version` field), read in place from `prp-manager/`. The test marketplace was removed afterwards.
- Namespaced invocation: in headless sessions, scratch copies of layouts A and B both listed `prp-manager:prp-manager` and answered `/prp-manager:prp-manager` from the loaded skill.
- Installed from this working copy, the session listed only `prp-manager`, not the namespaced skill. On this machine the user skills directory is a symlink to the same `prp-manager/` folder, so Claude Code loads that path once. This is specific to the development setup; the scratch copies, which live at a different path, were listed twice as the README warns.
- Install from GitHub at `932f3c9`: `Skills (1)  prp-manager`, version `932f3c9ab0b6`. The plugin cache holds only `SKILL.md`, `assets/` and `references/` (no README, PRPs or evals). A headless session listed `prp-manager:prp-manager` and answered from the skill. The test install was removed afterwards.
- Pending: submission to the official plugin directory (Task 5), done by the maintainer through the form.
