# PRP: Publish the Plugin for Cursor

> **Version:** 1.0
> **Created:** 2026-10-23
> **Status:** Implemented; submission pending (maintainer)
> **Issue:** https://github.com/willywg/prp-manager/issues/7

---

## Goal
Make `prp-manager/` a valid Cursor plugin and make the repository a one-plugin Cursor marketplace, the same way it already is for Claude Code. Then submit it to cursor.directory (community) and the official Cursor Marketplace. The skill content does not change.

## Why
- Cursor users can find and install the skill from inside Cursor instead of copying folders or running `npx skills`
- Cursor's own validator expects the same layout we already use for Claude: a root marketplace pointing at a plugin subfolder
- Precedent: obra/superpowers and cursor/plugins ship `.claude-plugin/` and `.cursor-plugin/` side by side

## What
A Cursor session started with the plugin loaded lists the `prp-manager` skill from `prp-manager/SKILL.md`. Cursor's `validate-plugins.mjs` passes on this repo. Claude Code and the Agent Skills validator are unaffected.

### Success Criteria
- [x] `prp-manager/.cursor-plugin/plugin.json` validates against Cursor's plugin schema, with no `skills` key
- [x] `.cursor-plugin/marketplace.json` at the repo root validates; Cursor's `validate-plugins.mjs` passes (it also checks that versions match across manifests)
- [x] `claude plugin validate ./prp-manager` and `claude plugin validate .` still pass
- [x] `agentskills validate ./prp-manager` still passes
- [x] A Cursor session with the plugin in `~/.cursor/plugins/local` lists the skill from the plugin path
- [x] CLAUDE.md and README updated (sync rule, tree, Cursor install)
- [ ] Submitted to cursor.directory and cursor.com/marketplace/publish (maintainer, web forms)

---

## All Needed Context

### Documentation & References
```yaml
- url: https://cursor.com/docs/reference/plugins
  why: Manifest location, fields, root SKILL.md rule, marketplace.json, submission checklist
- url: https://github.com/cursor/plugins/tree/main/schemas
  why: plugin.schema.json and marketplace.schema.json (what the validator enforces)
- url: https://github.com/cursor/plugins/blob/main/scripts/validate-plugins.mjs
  why: Cursor's validator: schema checks, name match, version match across manifests
- url: https://forum.cursor.com/t/cursor-plugin-submission/166867
  why: Community plugins go to cursor.directory/plugins/new; the official marketplace skews to company integrations
- url: https://forum.cursor.com/t/cursor-marketplace-submission/170458
  why: Staff: cursor.directory is "the recommended place for most plugins right now"
- file: prp-manager/.claude-plugin/plugin.json
  why: Source of the display fields to mirror
- file: .claude-plugin/marketplace.json
  why: Same one-entry marketplace pattern
- file: PRPs/003--claude-code-plugin.md
  why: Same plugin layout, proven in Claude Code and the Claude directory
```

### Desired Structure (files to add/modify)
```bash
.cursor-plugin/marketplace.json          # NEW: Cursor marketplace, one entry -> prp-manager
prp-manager/.cursor-plugin/plugin.json   # NEW: Cursor manifest (ignored by other agents)
CLAUDE.md                                # tree, sync rule for three manifests
README.md                                # Cursor install section, tree
PRPs/005--cursor-plugin.md               # this PRP
```

### Manifests
```json
// prp-manager/.cursor-plugin/plugin.json
{
  "name": "prp-manager",
  "displayName": "PRP Manager",
  "version": "1.3.0",
  "description": "<same as .claude-plugin/plugin.json>",
  "author": { "name": "William Wong Garay" },
  "homepage": "https://github.com/willywg/prp-manager",
  "repository": "https://github.com/willywg/prp-manager",
  "license": "MIT",
  "logo": ".claude-plugin/icon.png",
  "category": "productivity",
  "keywords": ["prp", "planning", "context-engineering", "spec", "agent-skill"]
}

// .cursor-plugin/marketplace.json
{
  "name": "prp-manager",
  "owner": { "name": "willywg" },
  "metadata": { "description": "<same as .claude-plugin/marketplace.json>" },
  "plugins": [{ "name": "prp-manager", "source": "prp-manager", "description": "<same>" }]
}
```

### Known Gotchas
```yaml
# CRITICAL: No "skills" key in the Cursor manifest. A root SKILL.md is a
#   single-skill plugin only when there is no skills/ folder and no skills field.
#   (The Claude manifest keeps "skills": ["./"]; the two files are independent.)
# SCHEMA: additionalProperties is false. Allowed: name, displayName, description,
#   version, author {name, email}, publisher, homepage, repository, license, logo,
#   keywords, category, tags, minClientVersions, variables. So no
#   author.url, documentationUrl or supportUrl (those stay Claude-only).
# VERSION: validate-plugins.mjs fails if .cursor-plugin, .claude-plugin and root
#   plugin.json versions differ. Keep all at 1.3.0 and bump them together.
# NO BUMP: adding a manifest for another agent does not change the skill, so the
#   version stays 1.3.0. Claude users would get nothing new from a bump, and every
#   new Claude directory version waits for a reviewer. Do not press "Publish update".
# LOGO: reuse .claude-plugin/icon.png (1024x1024 PNG) by relative path inside the
#   plugin root, no "..". Cursor resolves it to raw.githubusercontent.com at the SHA.
# MARKETPLACE: the submission points at the repo root, which has no plugin manifest,
#   so the root needs .cursor-plugin/marketplace.json with "source": "prp-manager"
#   (no "./" prefix in Cursor's examples). This file is outside the skill folder.
# NO ROOT plugin.json: the Agent Plugins format at the plugin root is not needed and
#   its effect on Claude Code / Codex is untested (see #8).
# LOCAL TEST: the maintainer also has the skill globally (~/.agents/skills and
#   ~/.claude/skills, both symlinks to this folder). Check the session reports the
#   plugin path, not just the skill name.
# DIRECTORY: cursor.directory has no one-click install for skills (deeplinks support
#   only rules), so the README keeps npx skills as the primary Cursor install.
```

---

## Implementation Blueprint

### Tasks (in execution order)
```yaml
Task 1: Add prp-manager/.cursor-plugin/plugin.json (manifest above)

Task 2: Add .cursor-plugin/marketplace.json at the repo root

Task 3: Validate (Levels 1-2)

Task 4: Sync docs
  - CLAUDE.md: tree; plugin rule mentions the Cursor manifests, the shared version,
    no skills key, no Claude-only fields
  - README.md: "Cursor (Plugin)" section after the Claude Code ones; tree

Task 5: Commit and push (maintainer's go-ahead)

Task 6: Submit (maintainer, web forms, signed in)
  - https://cursor.directory/plugins/new  -> repo URL
  - https://cursor.com/marketplace/publish -> repo URL
```

---

## Validation Loop

### Level 1: Schemas and existing validators
```bash
# Cursor's validator, run against a scratch copy of the repo with cursor/plugins'
# scripts/ and schemas/ dropped in (npm i ajv ajv-formats)
node scripts/validate-plugins.mjs
# Expected: "All plugins validated successfully."

claude plugin validate ./prp-manager && claude plugin validate .
uvx --from skills-ref agentskills validate ./prp-manager
# Expected: pass, same warnings as before
```

### Level 2: Behavior
```bash
cp -R prp-manager ~/.cursor/plugins/local/prp-manager
cursor-agent -p --trust \
  "Do not run any tools. For every skill whose name starts with prp-, print one line: name, absolute path of its SKILL.md, and its source."
# Expected: prp-manager, ~/.cursor/plugins/local/prp-manager/SKILL.md
rm -rf ~/.cursor/plugins/local/prp-manager   # clean up
```

---

## Notes

2026-10-23 (Cursor Agent CLI 2026.10.22):
- Cursor's `validate-plugins.mjs` and schemas, run on a scratch copy of the repo: "All plugins validated successfully."
- `claude plugin validate ./prp-manager` and `claude plugin validate .` pass; Claude Code ignores `.cursor-plugin/`. `agentskills validate`: "Valid skill: prp-manager".
- `--plugin-dir` did not load anything in `-p` mode, not even a control plugin with the standard `skills/<name>/SKILL.md` layout. Plugins copied into `~/.cursor/plugins/local/` do load: the control and a renamed copy of this plugin were both listed, the latter from its root `SKILL.md`, which confirms the single-skill rule with no `skills` key.
- With the real copy in `~/.cursor/plugins/local/`, the session listed `prp-manager` twice: from the plugin and from `~/.claude/skills/` (Cursor reads Claude's skills folder). The README says to keep only one copy. Test copies removed.
- Not used: `cursor-agent plugin marketplace add`, which registers a marketplace for the account; the maintainer's account belongs to a team.
- No version bump: the skill content is unchanged, all three manifests say 1.3.0.

