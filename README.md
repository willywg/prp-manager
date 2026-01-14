# PRP Manager - Agent Skill

An [Agent Skill](https://agentskills.io) for creating and executing PRPs (Product Requirements Prompts) using Context Engineering principles for one-pass implementation success.

Works with Claude Code, Cursor, Windsurf, Gemini CLI, VS Code, and [other compatible agents](https://agentskills.io/home).

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

```bash
# Clone the repository
git clone https://github.com/willywg/prp-manager.git
cd prp-manager

# Option 1: User-level (available in all projects)
cp -r prp-manager ~/.claude/skills/

# Option 2: Project-level (available only in current project)
mkdir -p /path/to/your/project/.claude/skills
cp -r prp-manager /path/to/your/project/.claude/skills/
```

After installation, verify the skill is available:
```bash
# The skill folder should be at one of these locations:
~/.claude/skills/prp-manager/SKILL.md           # User-level
.claude/skills/prp-manager/SKILL.md             # Project-level
```

### Claude.ai (Web)

1. Download this repository as a ZIP
2. Extract and compress only the `prp-manager/` folder into a new ZIP
3. Go to **Settings > Features**
4. Upload the ZIP file

> Note: Custom Skills on Claude.ai require Pro, Max, Team, or Enterprise plans with code execution enabled.

### Claude Desktop

1. Download this repository as a ZIP
2. Extract and compress only the `prp-manager/` folder into a new ZIP
3. Open Claude Desktop settings
4. Navigate to the Skills section
5. Upload the ZIP file

## Usage

The skill activates automatically when you mention PRPs or feature planning.

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

## Stack Detection

During initialization, Claude analyzes your project files to detect your stack and create an appropriate PRP template with the correct validation commands. The table below shows common configurations, but **Claude will adapt to whatever stack your project uses**.

| Stack | Package Manager | Linting | Testing |
|-------|----------------|---------|---------|
| Python | uv, pip | ruff, flake8, mypy | pytest |
| Node.js | npm, pnpm, yarn | eslint, biome | jest, vitest |
| TypeScript | npm, pnpm | tsc, biome | jest, vitest |

### Recommended: Provide Project Context

For best results, ensure your project has one or more of these files before initializing PRPs:

- **`CLAUDE.md`** or **`AGENTS.md`** - AI agent instructions and project rules
- **`README.md`** - Project overview and architecture
- **`CONTRIBUTING.md`** - Code style and contribution guidelines

These files give Claude more context about your project's conventions, patterns, and specific requirements, resulting in better customized PRP templates.

## Repository Structure

```
prp-manager/                  # Repository root
├── README.md                 # This file
├── LICENSE                   # MIT License
├── CLAUDE.md                 # Claude Code guidance for this repo
└── prp-manager/              # The skill (copy this folder)
    ├── SKILL.md              # Main skill instructions
    ├── assets/
    │   └── templates/
    │       └── prp_base.md   # Default PRP template
    └── references/
        ├── examples.md       # Usage examples
        └── customization.md  # Stack-specific customization guide
```

## Credits & Inspiration

This skill is based on the Context Engineering methodology:

- **PRP Framework**: Originally created by [Rasmus Widing (Wirasm)](https://github.com/Wirasm/PRPs-agentic-eng)
- **Context Engineering**: Popularized by [Cole Medin](https://github.com/coleam00) in [context-engineering-intro](https://github.com/coleam00/context-engineering-intro)

## Learn More

- [Agent Skills Specification](https://agentskills.io/specification)
- [What is Context Engineering?](https://github.com/coleam00/context-engineering-intro)
- [Original PRP Framework](https://github.com/Wirasm/PRPs-agentic-eng)

## License

MIT License - see [LICENSE](LICENSE) file for details.
