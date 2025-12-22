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
- url: [Official API docs URL]
  why: [Specific sections/methods needed]

- file: [path/to/example.py]
  why: [Pattern to follow, gotchas to avoid]

- doc: [Library documentation URL]
  section: [Specific section about common pitfalls]
  critical: [Key insight that prevents common errors]
```

### Current Codebase Structure
```bash
# Run: tree -L 2 in project root
```

### Desired Structure (files to add/modify)
```bash
# Show new files with comments about responsibility
src/
├── new_feature/
│   ├── __init__.py      # Module init
│   ├── service.py       # Core business logic
│   └── models.py        # Data models
```

### Known Gotchas & Library Quirks
```python
# CRITICAL: [Library name] requires [specific setup]
# Example: FastAPI requires async functions for endpoints
# Example: This ORM doesn't support batch inserts over 1000 records
```

---

## Implementation Blueprint

### Data Models
```python
# Core data models (ORM, Pydantic, etc.)
```

### Tasks (in execution order)
```yaml
Task 1: [Description]
  - MODIFY: src/existing_module.py
  - FIND pattern: "class OldImplementation"
  - INJECT after: "def __init__"
  - PRESERVE: existing method signatures

Task 2: [Description]
  - CREATE: src/new_feature.py
  - MIRROR pattern from: src/similar_feature.py
  - MODIFY: class name and core logic
  - KEEP: error handling pattern identical

Task 3: [Description]
  ...

Task N: [Description]
  ...
```

### Pseudocode (with CRITICAL details)
```python
# Task 1: [Description]
async def new_feature(param: str) -> Result:
    # PATTERN: Always validate input first (see src/validators.py)
    validated = validate_input(param)

    # GOTCHA: This library requires connection pooling
    async with get_connection() as conn:
        # CRITICAL: API returns 429 if >10 req/sec
        await rate_limiter.acquire()
        result = await external_api.call(validated)

    # PATTERN: Standardized response format
    return format_response(result)
```

### Integration Points
```yaml
DATABASE:
  - migration: "Add column 'feature_enabled' to users table"
  - index: "CREATE INDEX idx_feature_lookup ON users(feature_id)"

CONFIG:
  - add to: config/settings.py
  - pattern: "FEATURE_TIMEOUT = int(os.getenv('FEATURE_TIMEOUT', '30'))"

ROUTES:
  - add to: src/api/routes.py
  - pattern: "router.include_router(feature_router, prefix='/feature')"
```

---

## Validation Loop

### Level 1: Syntax & Style
```bash
# Run FIRST - fix errors before proceeding
ruff check src/new_feature.py --fix
mypy src/new_feature.py
```

### Level 2: Unit Tests
```python
# Test cases to create
def test_happy_path():
    """Basic functionality works"""
    result = new_feature("valid_input")
    assert result.status == "success"

def test_validation_error():
    """Invalid input raises ValidationError"""
    with pytest.raises(ValidationError):
        new_feature("")

def test_external_api_timeout():
    """Handles timeouts gracefully"""
    with mock.patch('external_api.call', side_effect=TimeoutError):
        result = new_feature("valid")
        assert result.status == "error"
```

```bash
# Run and iterate until passing
uv run pytest tests/test_new_feature.py -v
```

### Level 3: Integration Test
```bash
# Start service
uv run python -m src.main --dev

# Test endpoint
curl -X POST http://localhost:8000/feature \
  -H "Content-Type: application/json" \
  -d '{"param": "test_value"}'

# Expected: {"status": "success", "data": {...}}
```

---

## Final Checklist

- [ ] All tests pass: `uv run pytest tests/ -v`
- [ ] No linting errors: `uv run ruff check src/`
- [ ] No type errors: `uv run mypy src/`
- [ ] Manual test successful
- [ ] Error cases handled gracefully
- [ ] Logs are informative but not verbose
- [ ] Documentation updated if needed

---

## Anti-Patterns to Avoid

- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation because "it should work"
- ❌ Don't ignore failing tests - fix them
- ❌ Don't use sync functions in async context
- ❌ Don't hardcode values that should be config
- ❌ Don't catch all exceptions - be specific

---

## Notes

[Additional context, decisions made, or future considerations]
