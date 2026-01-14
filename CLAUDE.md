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
└── prp-manager/              # THE SKILL (this is what users install)
    ├── SKILL.md              # Main skill definition with frontmatter and workflows
    ├── assets/
    │   └── templates/
    │       └── prp_base.md   # Default PRP template
    └── references/
        ├── examples.md       # Usage examples showing the three workflows
        └── customization.md  # Stack-specific validation commands
```

**Important**: Only the `prp-manager/` subdirectory is the actual skill. The root-level files (README, LICENSE, CLAUDE.md) are for repository documentation and should not be copied when installing the skill.

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
- Follow the [Agent Skills specification](https://agentskills.io/specification)