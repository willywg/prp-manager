# PRP Manager - Claude Code Skill

A Claude Code skill for creating and executing PRPs (Product Requirements Prompts) using Context Engineering principles for one-pass implementation success.

## What is Context Engineering?

Context Engineering is a discipline for providing AI coding assistants with comprehensive information needed to complete tasks end-to-end. Unlike traditional prompt engineering (which focuses on clever wording for individual tasks), Context Engineering is a complete system including documentation, examples, rules, patterns, and validation mechanisms.

> "Most agent failures aren't model failures - they're context failures."

## What are PRPs?

**PRPs (Product Requirements Prompts)** are comprehensive implementation blueprints specifically designed for AI coding assistants. They are similar to traditional PRDs (Product Requirements Documents) but crafted to instruct AI rather than human teams.

A PRP provides the AI with:
- **Product Requirements**: What you're building and why
- **Curated Codebase Intelligence**: Examples, existing patterns, and conventions
- **Agent Runbook**: Step-by-step instructions including testing and validation

## Features

- **Initialize**: Analyzes your project and creates a customized PRP template based on your stack (Python/Node.js/etc.), linting tools, testing framework, and project conventions
- **Generate**: Creates comprehensive PRPs for new features with all necessary context
- **Execute**: Implements features following the PRP with validation loops

## Installation

### Claude Code (CLI)

Copy the skill folder to your Claude skills directory:

```bash
# Option 1: User-level (available in all projects)
git clone https://github.com/willywg/prp-manager.git
cp -r prp-manager ~/.claude/skills/

# Option 2: Project-level (available only in current project)
git clone https://github.com/willywg/prp-manager.git
cp -r prp-manager .claude/skills/
```

Or download and copy manually:
1. Download or clone this repository
2. Copy the `prp-manager` folder to `~/.claude/skills/` (user-level) or `.claude/skills/` (project-level)

### Claude.ai (Web)

1. Download this repository as a ZIP
2. Go to **Settings > Features**
3. Upload the ZIP file

> Note: Custom Skills on Claude.ai require Pro, Max, Team, or Enterprise plans with code execution enabled.

### Claude Desktop

1. Download this repository as a ZIP
2. Open Claude Desktop settings
3. Navigate to the Skills section
4. Upload the ZIP file

## Usage

The skill activates automatically when you mention PRPs or feature planning. You can also invoke it directly with `/prp-manager`.

### Workflow 1: Initialize PRPs (Recommended First)

```
User: "Initialize PRPs for this project"
```

Claude will:
1. Analyze your project files (README, package.json, CLAUDE.md, etc.)
2. Detect your stack and conventions
3. Create `PRPs/templates/prp_base.md` customized for your project

### Workflow 2: Generate a PRP

```
User: "Create a PRP for adding OAuth authentication with Google"
```

Claude will:
1. Research your codebase for similar patterns
2. Gather external documentation if needed
3. Create `PRPs/001--google-oauth.md` with full context

### Workflow 3: Execute a PRP

```
User: "Execute PRP PRPs/001--google-oauth.md"
```

Claude will:
1. Read and understand the PRP
2. Implement tasks in order
3. Run validation at each step
4. Report completion status

## Example Output

### After Initialize
```
PRPs Initialized for MyProject

Stack Detected:
- Language: Python 3.11
- Framework: FastAPI
- Package Manager: uv
- Linting: ruff
- Type Checking: mypy
- Testing: pytest

Created:
- PRPs/templates/prp_base.md

Ready to generate PRPs!
```

### After Generate
```
PRPs/005--feature-name.md

Confidence: 8/10
Key Notes: [implementation highlights]
```

### After Execute
```
PRP Execution Complete

Tasks: 5/5 completed
Validation: All passing
Status: SUCCESS
```

## Supported Stacks

The skill auto-detects and configures validation commands for:

| Stack | Package Manager | Linting | Testing |
|-------|----------------|---------|---------|
| Python | uv, pip | ruff, flake8, mypy | pytest |
| Node.js | npm, pnpm, yarn | eslint, biome | jest, vitest |
| TypeScript | npm, pnpm | tsc, biome | jest, vitest |

## File Structure

```
prp-manager/
├── SKILL.md              # Main skill instructions
├── README.md             # This file
├── LICENSE               # MIT License
├── templates/
│   └── prp_base.md       # Default PRP template
└── examples.md           # Usage examples
```

## Credits & Inspiration

This skill is based on the Context Engineering methodology:

- **PRP Framework**: Originally created by [Rasmus Widing (Wirasm)](https://github.com/Wirasm/PRPs-agentic-eng)
- **Context Engineering**: Popularized by [Cole Medin](https://github.com/coleam00) in [context-engineering-intro](https://github.com/coleam00/context-engineering-intro)

## Learn More

- [What is Context Engineering?](https://github.com/coleam00/context-engineering-intro)
- [Original PRP Framework](https://github.com/Wirasm/PRPs-agentic-eng)
- [Claude Code Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Agent Skills Best Practices](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/best-practices)

## License

MIT License - see [LICENSE](LICENSE) file for details.
