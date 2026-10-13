# PRP: [Feature Name]

> **Version:** 1.0
> **Created:** [Date]
> **Status:** Draft | Ready | In Progress | Completed

---

## Goal
[What needs to be built - be specific about the end state]

## Why
- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves and for whom]

## What
[User-visible behavior and technical requirements]

### Success Criteria
- [ ] [Specific measurable outcome 1]
- [ ] [Specific measurable outcome 2]
- [ ] [Specific measurable outcome 3]

---

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- url: [Official docs URL]
  why: [Specific sections/methods needed]

- file: [path/to/similar_feature]
  why: [Pattern to follow, gotchas to avoid]

- doc: [Library documentation URL]
  section: [Specific section about common pitfalls]
  critical: [Key insight that prevents common errors]
```

### Current Codebase Structure
```text
[Output of the project tree, 2 levels deep, limited to relevant folders]
```

### Desired Structure (files to add/modify)
```text
[path/to/new_module]/
├── [new_file]        # [Responsibility]
└── [new_file]        # [Responsibility]
[path/to/existing_file]   # MODIFY: [what changes]
```

### Known Gotchas & Library Quirks
```text
CRITICAL: [Library name] requires [specific setup]
GOTCHA: [Behavior that defies a reasonable assumption]
LIMIT: [Rate limit, size limit or version constraint]
```

---

## Implementation Blueprint

### Data Models
```text
[Types, schemas or tables this feature adds or changes, in the project's
language. Remove this section if the feature has none.]
```

### Tasks (in execution order)
```yaml
Task 1: [Description]
  - MODIFY: [path/to/existing_file]
  - FIND pattern: "[existing symbol or text]"
  - INJECT after: "[anchor]"
  - PRESERVE: existing public signatures

Task 2: [Description]
  - CREATE: [path/to/new_file]
  - MIRROR pattern from: [path/to/similar_file]
  - MODIFY: names and core logic
  - KEEP: error handling pattern identical

Task N: [Description]
  ...
```

### Pseudocode (with CRITICAL details)
```text
# Task 1: [Description]
function new_feature(param):
    # PATTERN: Validate input first (see [path/to/validators])
    validated = validate(param)

    # GOTCHA: [Resource] must be acquired through [existing helper]
    # CRITICAL: [External constraint, e.g. API returns 429 above 10 req/sec]
    result = call_dependency(validated)

    # PATTERN: Return the project's standard response shape
    return format_response(result)
```

### Integration Points
```yaml
DATA:
  - [Migration, schema or storage change, or "none"]

CONFIG:
  - add to: [path/to/config]
  - pattern: "[How settings are declared in this project]"

ENTRY POINTS:
  - add to: [path/to/routes, CLI, or module index]
  - pattern: "[How features are registered in this project]"
```

---

## Validation Loop

### Level 1: Syntax & Style
```bash
# Run FIRST - fix errors before proceeding
[lint command]
[type check command]
```

### Level 2: Unit Tests
```text
Test cases to create in [path/to/tests], following [existing test file]:
- Happy path: [input] -> [expected result]
- Invalid input: [input] -> [expected error]
- Dependency failure: [timeout or error] -> [expected handling]
```

```bash
# Run and iterate until passing
[test command for the new tests]
```

### Level 3: Integration Test
```bash
# Start or build the project
[start command]

# Exercise the feature end to end
[request, CLI call or script that exercises the feature]

# Expected: [observable result]
```

---

## Final Checklist

- [ ] All tests pass: `[full test command]`
- [ ] No linting errors: `[lint command]`
- [ ] No type errors: `[type check command]`
- [ ] Manual test successful
- [ ] Error cases handled gracefully
- [ ] Logs are informative but not verbose
- [ ] Documentation updated if needed

---

## Anti-Patterns to Avoid

- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation because "it should work"
- ❌ Don't ignore failing tests - fix them
- ❌ Don't hardcode values that should be config
- ❌ Don't catch all exceptions - be specific

---

## Notes

[Additional context, decisions made, or future considerations]
