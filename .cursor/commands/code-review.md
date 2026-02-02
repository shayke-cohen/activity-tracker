# Code Review

## Overview
Review code changes in the current branch before committing or pushing, compared to main/master.

## Prerequisites
- On a feature branch (not main/master)
- Changes to review (staged, unstaged, or committed)

## Steps

1. **Identify what to review**:
   ```bash
   # Unstaged changes
   git diff
   
   # Staged changes
   git diff --staged
   
   # All changes vs main
   git diff main...HEAD
   ```

2. **Get list of changed files**:
   ```bash
   git diff --name-only main...HEAD
   ```

3. **Review each changed file** for:

   ### Code Quality
   - Logic errors or bugs
   - Edge cases not handled
   - Error handling gaps
   - Code duplication
   - Complexity that could be simplified
   
   ### Security
   - Hardcoded secrets or credentials
   - SQL injection vulnerabilities
   - XSS vulnerabilities
   - Unsafe input handling
   - Exposed sensitive data in logs
   
   ### Best Practices
   - Naming conventions
   - Function/method length
   - Single responsibility principle
   - Proper typing (TypeScript)
   - Consistent code style
   
   ### Testing
   - New code has tests
   - Edge cases tested
   - Mocks used appropriately
   
   ### Documentation
   - Comments for complex logic
   - JSDoc/docstrings for public APIs
   - README updates if needed

4. **Check for common issues**:
   - Console.log statements left in
   - TODO comments that should be addressed
   - Commented-out code
   - Debug code

5. **Compile findings into report**

## Output

```
## Code Review: feature/issue-23-user-auth

### Files Changed
- src/services/auth.ts (modified)
- src/utils/validation.ts (new)
- tests/auth.test.ts (modified)

### Summary
Overall: Ready with minor suggestions

### Issues Found

#### Critical (must fix)
None

#### Warnings (should fix)
1. **src/services/auth.ts:45** - Password logged in debug mode
   ```typescript
   console.log('Login attempt:', { email, password }); // Remove password
   ```

2. **src/utils/validation.ts:12** - Missing input sanitization
   ```typescript
   // Add: email = sanitize(email);
   ```

#### Suggestions (nice to have)
1. **src/services/auth.ts:78** - Consider extracting to helper
   - The token generation logic (lines 78-95) could be a separate function

2. **tests/auth.test.ts** - Add edge case test
   - Missing test for expired token scenario

### Security Check
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Error messages don't leak info
- [x] Sensitive data in logs ← Found issue #1

### Testing Coverage
- New functions: 2/2 have tests
- Edge cases: 3/5 covered

### Ready to Commit?
Almost - fix the password logging issue first.
```

## Review Depth Options

- **Quick review**: Focus on critical issues only
- **Standard review**: All categories (default)
- **Deep review**: Line-by-line analysis with suggestions
- **Security focused**: Emphasize security checks
