# PRP Manager Examples

Examples 1 to 3 follow one project through the three workflows: a TypeScript REST API using pnpm, Express, Biome and Vitest. The stack is only an illustration. Every command in a PRP comes from the project being worked on (see [customization.md](customization.md)); Examples 4 and 5 show the cases that differ.

## Example 1: Initialize PRPs

**User**: "Set up PRPs for this project"

**Agent**:
1. Checks that `PRPs/templates/prp_base.md` does not exist
2. Reads AGENTS.md, README.md, package.json, biome.json, tsconfig.json and the existing tests
3. Copies the bundled template and replaces each command placeholder with the project's command

**Analysis**:
```
Found:
- AGENTS.md: "All handlers validate input with zod", "Put DB access in src/repositories/"
- package.json scripts: lint, typecheck, test, dev
- tests next to sources: src/**/*.test.ts

Stack Detected:
- Language: TypeScript 5 (Node 20)
- Framework: Express
- Package Manager: pnpm
- Linting: Biome
- Type Checking: tsc
- Testing: Vitest
```

**Command placeholders resolved**:

| Placeholder | Command in the generated template |
|-------------|-----------------------------------|
| `[lint command]` | `pnpm biome check --write src/` |
| `[type check command]` | `pnpm tsc --noEmit` |
| `[test command for the new tests]` | `pnpm vitest run src/path/to/feature.test.ts` |
| `[full test command]` | `pnpm vitest run` |
| `[start command]` | `pnpm dev` |

**Generated** `PRPs/templates/prp_base.md` (excerpt: the sections that changed; the rest keeps the bundled structure):

````markdown
### Known Gotchas & Library Quirks
```text
# From AGENTS.md:
# - Validate every request body with zod before using it
# - Database access only through src/repositories/
```

## Validation Loop

### Level 1: Syntax & Style
```bash
# Run FIRST - fix errors before proceeding
pnpm biome check --write src/
pnpm tsc --noEmit
```

### Level 2: Unit Tests
```bash
# Run and iterate until passing
pnpm vitest run src/path/to/feature.test.ts
```

### Level 3: Integration Test
```bash
pnpm dev
curl -i http://localhost:3000/[endpoint]
# Expected: [observable result]
```

## Final Checklist
- [ ] All tests pass: `pnpm vitest run`
- [ ] No linting errors: `pnpm biome check src/`
- [ ] No type errors: `pnpm tsc --noEmit`
````

Content placeholders such as `[endpoint]` and `[observable result]` stay; they are filled in each PRP.

**Summary**:
```
✅ PRPs Initialized for orders-api

Stack Detected:
- Language: TypeScript 5
- Framework: Express
- Package Manager: pnpm
- Linting: Biome
- Type Checking: tsc
- Testing: Vitest

Special Rules Applied:
- zod validation and repository rule added to Known Gotchas

Created:
- PRPs/templates/prp_base.md

Ready to generate PRPs!
```

---

## Example 2: Generate a PRP

**User**: "Plan sign-in with Google before we build it"

**Agent**:
1. Confirms `PRPs/templates/prp_base.md` exists
2. Finds the current auth code (`src/auth/session.ts`, `src/routes/auth.ts`) and its tests
3. Reads Google's OAuth 2.0 web server guide
4. Lists existing PRPs to pick the next number, then writes the PRP from the project template

**Output**: `PRPs/005--google-sign-in.md` (excerpt)

````markdown
# PRP: Google Sign-In

## Goal
Users can sign in with a Google account. Existing email and password login keeps working.

### Success Criteria
- [ ] GET /auth/google redirects to Google's consent screen
- [ ] The callback creates or links the user and starts a session
- [ ] A callback with an invalid `state` returns 400 and creates no session

## All Needed Context

### Documentation & References
```yaml
- url: https://developers.google.com/identity/protocols/oauth2/web-server
  why: Authorization code flow, state parameter, token exchange

- file: src/auth/session.ts
  why: How sessions are created today; reuse createSession()

- file: src/routes/auth.test.ts
  why: Test pattern for routes (supertest + in-memory repository)
```

### Known Gotchas & Library Quirks
```text
# - Validate the callback query with zod (AGENTS.md)
# - Google requires the exact redirect URI registered in the console
# - Store `state` in the session before redirecting; compare on callback
```

## Implementation Blueprint

### Tasks (in execution order)
```yaml
Task 1: Config
  - MODIFY: src/config.ts
  - ADD: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI

Task 2: Google client
  - CREATE: src/auth/google.ts
  - PATTERN: follow src/auth/session.ts

Task 3: Routes
  - MODIFY: src/routes/auth.ts
  - ADD: GET /auth/google, GET /auth/google/callback

Task 4: Tests
  - CREATE: src/routes/auth.google.test.ts
```

## Validation Loop

### Level 1: Syntax & Style
```bash
pnpm biome check --write src/
pnpm tsc --noEmit
```

### Level 2: Unit Tests
```bash
pnpm vitest run src/routes/auth.google.test.ts
```

### Level 3: Integration Test
```bash
pnpm dev
curl -i http://localhost:3000/auth/google
# Expected: 302 with Location starting https://accounts.google.com/
```
````

**Confidence**: 8/10. Main risk: the redirect URI must match the Google console exactly.

---

## Example 3: Execute a PRP

**User**: "Execute PRPs/005--google-sign-in.md"

**Agent**:
1. Reads the whole PRP and the files it references
2. Turns the tasks into a task list
3. Implements them in order, running Level 1 after each file
4. Runs Level 2 and Level 3, fixing failures and re-running until they pass
5. Re-reads the success criteria and reports

**Output**:
```
✅ PRP Execution Complete: Google Sign-In

Tasks: 4/4 completed
Validation:
- pnpm biome check: no errors
- pnpm tsc --noEmit: no errors
- pnpm vitest run: 41 passed (6 new)
- curl /auth/google: 302 to accounts.google.com
Status: SUCCESS
```

---

## Example 4: No Template Yet

**User**: "Write a PRP for adding websockets" (no `PRPs/templates/prp_base.md`)

**Agent**:
```
This project doesn't have a PRP template yet. Would you like me to initialize
PRPs first? I'll read your stack and conventions and create a customized
template at PRPs/templates/prp_base.md.
```

If the user declines, the agent writes this PRP from the bundled template and still resolves its command placeholders from the project's files. The PRP never contains `[lint command]` or similar.

---

## Example 5: A Tool the Project Lacks

**User**: "Initialize PRPs" (in a Go service)

**Detected**:
```
Language: Go 1.22
Package Manager: go modules
Linting: go vet (no golangci-lint config)
Type Checking: none separate (the compiler checks types)
Testing: go test
```

**Generated validation commands**:
```bash
# Level 1: Syntax & Style
gofmt -l .
go vet ./...

# Level 2: Unit Tests
go test ./internal/orders/...

# Level 3: Integration Test
go run ./cmd/server
```

`[type check command]` has no Go equivalent, so its lines are deleted from the template instead of being filled with an invented command.
