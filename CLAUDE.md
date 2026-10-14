# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PRP Manager is an [Agent Skill](https://agentskills.io) for creating and executing PRPs (Product Requirements Prompts) using Context Engineering principles. It enables AI agents to implement features with comprehensive context for one-pass implementation success.

**This is an Agent Skill, not a traditional codebase with source code.** It consists of markdown files that define skill behavior.

## Repository Structure

```
prp-manager/                  # Repository root (development files)
├── README.md                 # Installation and usage documentation
├── LICENSE                   # MIT License
├── CLAUDE.md                 # This file
├── .claude-plugin/
│   └── marketplace.json      # Claude Code plugin marketplace; its one entry points at prp-manager/
├── PRPs/                     # PRPs for developing this repo (not part of the skill)
│   └── templates/
│       └── prp_base.md       # This repo's own PRP template
├── evals/                    # Trigger eval for the skill description (not part of the skill)
└── prp-manager/              # THE SKILL (this is what users install)
    ├── .claude-plugin/
    │   └── plugin.json       # Claude Code plugin manifest (ignored by other agents)
    ├── SKILL.md              # Main skill definition with frontmatter and workflows
    ├── assets/
    │   └── templates/
    │       └── prp_base.md   # Default PRP template
    └── references/
        ├── examples.md       # Usage examples showing the three workflows
        └── customization.md  # Stack-specific validation commands
```

**Important**: Only the `prp-manager/` subdirectory is the actual skill. The root-level files (README, LICENSE, CLAUDE.md) , `PRPs/` and `evals/` are for repository documentation and development, and should not be copied when installing the skill.

`PRPs/templates/prp_base.md` is this repo's own template (the skill used on itself). The template shipped to users is `prp-manager/assets/templates/prp_base.md`.

## Key Concepts

**PRPs (Product Requirements Prompts)**: Implementation blueprints for AI that include product requirements, curated codebase intelligence, and agent runbooks with validation steps.

**Context Engineering**: A discipline for providing AI with comprehensive information needed to complete tasks end-to-end, including documentation, examples, rules, patterns, and validation mechanisms.

## Three Workflows

1. **Initialize** (`PRPs/templates/prp_base.md`) - Analyzes project files to create a customized PRP template with project-specific validation commands
2. **Generate** (`PRPs/NNN--feature-name.md`) - Creates comprehensive PRPs for new features using the project template
3. **Execute** - Implements features following PRP instructions with validation loops

## When Editing This Skill

- The `SKILL.md` frontmatter (name, description, compatibility) is used for skill discovery
- Workflow sections in `SKILL.md` must remain structured with clear steps
- Stack-specific customization is in `references/customization.md`
- Examples in `references/examples.md` should demonstrate realistic usage scenarios
- Keep skill files (`prp-manager/`) separate from repo documentation (root files)
- The Claude Code plugin is `prp-manager/.claude-plugin/plugin.json` (`"skills": ["./"]`, because SKILL.md sits at the plugin root). The root `.claude-plugin/marketplace.json` lists it. Keep display fields (description, keywords) in sync between the two. Neither sets `version`, so installs track commits. The directory submission form needs `plugin.json` in the folder it is pointed at (`prp-manager`). After editing either file run `claude plugin validate ./prp-manager` and `claude plugin validate .`
- Follow the [Agent Skills specification](https://agentskills.io/specification)