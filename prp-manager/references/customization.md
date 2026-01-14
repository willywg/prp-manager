# Template Customization Guide

When generating `PRPs/templates/prp_base.md`, adapt these sections based on the detected project stack.

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

## Special Rules to Include

From AGENTS.md/CLAUDE.md/GEMINI.md, extract and include:

- Code style preferences
- Architectural patterns to follow
- Libraries to use/avoid
- Testing requirements
- Documentation standards