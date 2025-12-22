# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PRP Manager is a Claude Code skill for creating and executing PRPs (Product Requirements Prompts) using Context Engineering principles. It enables AI agents to implement features with comprehensive context for one-pass implementation success.

**This is a Claude Code skill, not a traditional codebase with source code.** It consists of markdown files that define skill behavior.

## Project Structure

- `SKILL.md` - Main skill definition with frontmatter metadata and workflow instructions
- `templates/prp_base.md` - Default PRP template used as fallback or base for customization
- `examples.md` - Usage examples showing the three workflows
- `README.md` - Installation and usage documentation

## Key Concepts

**PRPs (Product Requirements Prompts)**: Implementation blueprints for AI that include product requirements, curated codebase intelligence, and agent runbooks with validation steps.

**Context Engineering**: A discipline for providing AI with comprehensive information needed to complete tasks end-to-end, including documentation, examples, rules, patterns, and validation mechanisms.

## Three Workflows

1. **Initialize** (`PRPs/templates/prp_base.md`) - Analyzes project files to create a customized PRP template with project-specific validation commands
2. **Generate** (`PRPs/NNN--feature-name.md`) - Creates comprehensive PRPs for new features using the project template
3. **Execute** - Implements features following PRP instructions with validation loops

## When Editing This Skill

- The `SKILL.md` frontmatter (name, description) is used by Claude Code for skill discovery
- Workflow sections in `SKILL.md` must remain structured with clear steps
- Template customization guidance in `SKILL.md` should cover common stacks (Python, Node.js, TypeScript)
- Examples in `examples.md` should demonstrate realistic usage scenarios
