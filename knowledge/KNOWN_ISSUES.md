# Known Issues

> This file documents known pitfalls and their solutions.
> Check here before starting work to avoid repeating mistakes.

---

## Template

When adding a new known issue, use this format:

```markdown
## [ISSUE-ID] Brief Title

**Date:** YYYY-MM-DD
**Severity:** High/Medium/Low
**Symptoms:** What went wrong, error messages
**Root Cause:** Why it happened
**Solution:** How it was fixed
**Prevention:** How to avoid in future
**Related:** Links to PRs, commits, other issues
```

---

## Active Known Issues

<!-- Add known issues below this line -->

### Example Entry (Delete When Adding Real Issues)

## [KI-001] Example: Race Condition in User Authentication

**Date:** 2024-01-16
**Severity:** Medium
**Symptoms:** Users occasionally logged in as wrong user. Console showed: "Session mismatch error"
**Root Cause:** Session was being set before user validation completed due to async timing issue.
**Solution:** Added `await` before session assignment in `auth.service.ts:45`. See PR #42.
**Prevention:** Always await async operations before using their results. Add race condition tests for auth flows.
**Related:** #41, PR #42

---

## Resolved Issues

<!-- Move resolved issues here with resolution date -->
