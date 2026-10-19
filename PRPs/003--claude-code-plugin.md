# PRP: Distribute the Skill as a Claude Code Plugin

> **Version:** 1.0
> **Created:** 2026-10-13
> **Status:** Completed
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
- [x] Submitted to the official plugin directory

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

### Change after the first directory submission attempt (2026-10-14)

The directory submission form validates a plugin folder, not a marketplace. Pointed at `prp-manager`, it blocked with "This folder is not a plugin ... add .claude-plugin/plugin.json with at least {"name": "…"}". The `strict: false` entry with no `plugin.json` works for installs but not for the directory.

Fix: add `prp-manager/.claude-plugin/plugin.json` with `"skills": ["./"]` and the display fields, and reduce the marketplace entry to name, source, description and category. With `plugin.json` present the entry must not declare `skills`, or with `strict: false` the plugin fails to load with conflicting manifests. Checked in a scratch copy: both manifests validate (one warning: no `version`), `agentskills validate` passes, and a local install lists `Skills (1)  prp-manager`.

Trade-off: `npx skills` users now also receive the small `.claude-plugin/plugin.json`. Other agents ignore it.

### Directory lints (2026-10-14)

After the plugin.json change the form passed with two warnings, both resolved:
- No version: `plugin.json` now sets `"version": "1.3.0"`, matching `metadata.version` in SKILL.md. This replaces the earlier "no version, track commits" decision: users now update only when the version is bumped, so bump both on every skill change.
- No icon: added `prp-manager/.claude-plugin/icon.png` (1024x1024, opaque, square corners so the directory can apply its own mask) and `"icon"` in plugin.json. The directory reads the icon only on the first save or submission.

### Directory approval (2026-10-19)

Submitted on 2026-10-14 with auto-publish on and the GitHub push webhook connected. v1.3.0 (`379c267`) was approved and published by the directory team, listed in Claude Code, Cowork and the Claude apps. The directory warnings were only the expected ones: `documentationUrl` and `supportUrl` as unrecognized fields ("No action needed") and the icon passing without a code check.

- Install id: `prp-manager@anthropic-plugin-directory`. The directory pins the plugin as a `git-subdir` source (path `prp-manager`) at the approved SHA. Checked with `claude plugin install` and `claude plugin details` (`Skills (1)  prp-manager`); the test install was removed.
- The panel says auto-publish does not apply for now: every version waits for an Anthropic reviewer. Group skill changes into fewer releases.
- Follow-up distribution for other agents: #6 (Grok Build), #7 (Cursor), #8 (Codex).
