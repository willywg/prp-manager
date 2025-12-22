# PRP Manager Examples

## Example 1: Initialize PRPs (First Time Setup)

**User**: "Inicializa PRPs para este proyecto" o "Crea un PRP para X" (cuando no existe template)

**Claude**:
1. Detects no `PRPs/templates/prp_base.md` exists
2. Analyzes project files (README, CLAUDE.md, package.json, etc.)
3. Detects stack and conventions
4. Generates customized template

**Analysis Output**:
```
Analyzing project...

Found:
- AGENTS.md ✓ (universal agent guidance)
- CLAUDE.md ✓ (Claude-specific rules)
- README.md ✓
- pyproject.toml ✓
- ruff.toml ✓
- tests/ directory ✓

Stack Detected:
- Language: Python 3.11
- Framework: FastAPI
- Package Manager: uv
- Linting: ruff (with custom rules)
- Type Checking: mypy (strict mode)
- Testing: pytest with pytest-asyncio

Special Rules from CLAUDE.md:
- Always use async/await for I/O operations
- Follow existing patterns in src/services/
- Run tests before committing
```

**Generated**: `PRPs/templates/prp_base.md`

```markdown
# PRP: [Feature Name]

> **Project:** MyFastAPI App
> **Version:** 1.0
> **Status:** Draft | Ready | In Progress | Completed

---

## Goal
[What needs to be built]

## Why
- [Business value]

## What
[Technical requirements]

### Success Criteria
- [ ] [Measurable outcome]

---

## All Needed Context

### Documentation & References
```yaml
- url: [docs URL]
  why: [reason]

- file: [path]
  why: [pattern to follow]
```

### Current Codebase Structure
```bash
# Run: tree -L 2 src/
```

### Known Gotchas
```python
# From CLAUDE.md:
# - Always use async/await for I/O operations
# - Follow patterns in src/services/
```

---

## Implementation Blueprint

### Tasks
```yaml
Task 1: [Description]
  - MODIFY/CREATE: path/to/file.py
  - PATTERN: Follow src/services/ structure
```

---

## Validation Loop

### Level 1: Syntax & Style
```bash
# Project-specific commands
uv run ruff check src/ --fix
uv run mypy src/ --strict
```

### Level 2: Tests
```bash
uv run pytest tests/ -v --asyncio-mode=auto
```

### Level 3: Integration
```bash
uv run python -m src.main --dev
curl http://localhost:8000/health
```

---

## Final Checklist
- [ ] All tests pass: `uv run pytest tests/ -v`
- [ ] No linting errors: `uv run ruff check src/`
- [ ] No type errors: `uv run mypy src/ --strict`
- [ ] Manual test successful
- [ ] Follows patterns from src/services/
```

**Summary**:
```
✅ PRPs Initialized for MyFastAPI App

Stack Detected:
- Language: Python 3.11
- Framework: FastAPI
- Package Manager: uv
- Linting: ruff
- Type Checking: mypy (strict)
- Testing: pytest + pytest-asyncio

Special Rules Applied:
- Async/await requirement noted in gotchas
- Pattern references to src/services/
- Strict mypy mode in validation

Created:
- PRPs/templates/prp_base.md

Ready to generate PRPs!
```

---

## Example 2: Generate PRP (After Initialize)

**User**: "Crea un PRP para agregar autenticación con OAuth2 usando Google"

**Claude**:
1. Checks `PRPs/templates/prp_base.md` exists ✓
2. Researches codebase for auth patterns
3. Checks external docs for Google OAuth2
4. Creates PRP using project template

**Output**: `PRPs/005--google-oauth2-auth.md`

```markdown
# PRP: Google OAuth2 Authentication

> **Project:** MyFastAPI App
> **Version:** 1.0
> **Status:** Ready

---

## Goal
Implement Google OAuth2 authentication allowing users to sign in with their Google accounts.

## Why
- Reduce friction for user signup/login
- Leverage Google's security infrastructure
- Users already trust Google authentication

## What
- "Sign in with Google" button on login page
- OAuth2 flow with proper token handling
- User profile sync from Google

### Success Criteria
- [ ] Users can sign in with Google account
- [ ] Profile picture and name synced from Google
- [ ] Existing password login still works

---

## All Needed Context

### Documentation & References
```yaml
- url: https://developers.google.com/identity/protocols/oauth2/web-server
  why: Server-side OAuth2 flow

- file: src/services/auth_service.py
  why: Existing auth pattern to follow

- doc: https://docs.authlib.org/en/latest/client/fastapi.html
  critical: Use async client
```

### Known Gotchas
```python
# From CLAUDE.md:
# - Always use async/await for I/O operations
# - Follow patterns in src/services/

# OAuth specific:
# - Google OAuth requires HTTPS in production
# - Token refresh must happen before expiry
```

---

## Implementation Blueprint

### Tasks
```yaml
Task 1: Add configuration
  - MODIFY: src/config/settings.py
  - ADD: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET

Task 2: Create OAuth service
  - CREATE: src/services/oauth_google_service.py
  - PATTERN: Follow src/services/auth_service.py

Task 3: Add endpoints
  - MODIFY: src/api/routes/auth.py
  - ADD: /auth/google/login, /auth/google/callback

Task 4: Add tests
  - CREATE: tests/test_oauth_google.py
```

---

## Validation Loop

### Level 1: Syntax & Style
```bash
uv run ruff check src/services/oauth_google_service.py --fix
uv run mypy src/services/oauth_google_service.py --strict
```

### Level 2: Tests
```bash
uv run pytest tests/test_oauth_google.py -v --asyncio-mode=auto
```

### Level 3: Integration
```bash
uv run python -m src.main --dev
open http://localhost:8000/auth/google/login
```

---

## Final Checklist
- [ ] All tests pass
- [ ] No linting errors
- [ ] No type errors (strict mode)
- [ ] Manual OAuth flow works
- [ ] Follows src/services/ patterns
```

**Confidence Score: 8/10**

---

## Example 3: Execute PRP

**User**: "Ejecuta el PRP PRPs/005--google-oauth2-auth.md"

**Claude**:
1. Reads the PRP file
2. Creates todo list from tasks
3. Executes in order
4. Runs validation at each step
5. Reports final status

**Output**:
```
✅ PRP Execution Complete: Google OAuth2 Authentication

Tasks Completed:
1. ✅ Added configuration to settings.py
2. ✅ Created oauth_google_service.py
3. ✅ Added OAuth endpoints
4. ✅ Created test suite

Validation Results:
- ruff check: ✅ No errors
- mypy --strict: ✅ No type errors
- pytest: ✅ 8 tests passed
- Manual test: ✅ OAuth flow working

Final Status: SUCCESS
```

---

## Example 4: Auto-Suggest Initialize

**User**: "Crea un PRP para agregar websockets" (no template exists)

**Claude**:
```
I notice this project doesn't have a PRP template yet.

Would you like me to initialize PRPs first? This will:
1. Analyze your project's stack and conventions
2. Read AGENTS.md/CLAUDE.md/GEMINI.md for AI agent rules
3. Create a customized template at PRPs/templates/prp_base.md

This ensures all PRPs follow your project's patterns and validation commands.

[Initialize PRPs] [Skip and use generic template]
```

---

## Example 5: Node.js Project Initialize

**User**: "Inicializa PRPs" (in a Next.js project)

**Detected**:
```
Stack Detected:
- Language: TypeScript
- Framework: Next.js 14
- Package Manager: pnpm
- Linting: biome
- Testing: vitest
```

**Generated validation commands**:
```bash
# Level 1: Syntax & Style
pnpm biome check src/
pnpm tsc --noEmit

# Level 2: Tests
pnpm vitest run

# Level 3: Integration
pnpm dev
curl http://localhost:3000/api/health
```
