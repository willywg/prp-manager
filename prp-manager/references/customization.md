# Template Customization Guide

When generating `PRPs/templates/prp_base.md`, adapt these sections based on the detected project stack.

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

## Validation Commands by Stack

### Python (uv + ruff + mypy + pytest)

```bash
# Level 1: Syntax & Style
uv run ruff check src/ --fix
uv run mypy src/

# Level 2: Tests
uv run pytest tests/ -v
```

### Python (pip + flake8 + pytest)

```bash
# Level 1: Syntax & Style
flake8 src/
python -m mypy src/

# Level 2: Tests
python -m pytest tests/ -v
```

### Node.js (npm + eslint + jest)

```bash
# Level 1: Syntax & Style
npm run lint
npm run typecheck  # if TypeScript

# Level 2: Tests
npm test
```

### Node.js (pnpm + biome + vitest)

```bash
# Level 1: Syntax & Style
pnpm biome check src/

# Level 2: Tests
pnpm vitest run
```

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

## Special Rules to Include

From AGENTS.md/CLAUDE.md/GEMINI.md, extract and include:

- Code style preferences
- Architectural patterns to follow
- Libraries to use/avoid
- Testing requirements
- Documentation standards