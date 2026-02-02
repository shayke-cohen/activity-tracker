# Testing Guide

> **Last Updated:** 2024-01-16

This document describes testing practices for the project.

---

## Quick Reference

```bash
# Run all tests
yarn test

# Run with coverage
yarn test --coverage

# Run specific test file
yarn test path/to/test.ts

# Watch mode
yarn test --watch

# Run linter
yarn lint

# Run linter with auto-fix
yarn lint:fix

# Type check
yarn typecheck
```

---

## Test Pyramid

```
        ┌─────────┐
        │   E2E   │  ← Few, slow, high confidence
        ├─────────┤
        │ Integr. │  ← Some, medium speed
        ├─────────┤
        │  Unit   │  ← Many, fast, focused
        └─────────┘
```

| Type | Quantity | Speed | What it Tests |
|------|----------|-------|---------------|
| **Unit** | Many (70%) | Fast | Single functions/classes in isolation |
| **Integration** | Some (20%) | Medium | Component interactions, API calls |
| **E2E** | Few (10%) | Slow | Full user flows, critical paths |

---

## When to Write Tests

### ✅ ALWAYS Write Tests For

| Scenario | Test Type | Why |
|----------|-----------|-----|
| **New feature** | Unit + Integration | Verify behavior works as designed |
| **Bug fix** | Regression test | Prevent bug from recurring |
| **API endpoint** | Integration | Verify contract |
| **Business logic** | Unit | Core functionality must be tested |
| **Data transformations** | Unit | Ensure data integrity |
| **Edge cases found** | Unit | Document and prevent |

### ⚠️ Consider Tests For

| Scenario | When to Test |
|----------|--------------|
| Refactoring | If existing tests are insufficient |
| UI components | For complex logic, skip pure styling |
| Configuration | If complex conditional logic |

### ❌ Skip Tests For

| Scenario | Why |
|----------|-----|
| Generated code | Auto-generated, test generator instead |
| Simple getters/setters | No logic to test |
| Framework code | Trust the framework |
| One-off scripts | Unless reused |

---

## Test File Organization

```
tests/
├── unit/
│   ├── services/
│   │   └── user.service.test.ts
│   └── utils/
│       └── helpers.test.ts
├── integration/
│   ├── api/
│   │   └── users.api.test.ts
│   └── database/
│       └── user.repository.test.ts
└── e2e/
    └── flows/
        └── user-registration.e2e.ts
```

---

## Test Naming Convention

```typescript
// Pattern: describe what, given what, expect what
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user when valid data provided', () => {});
    it('should throw ValidationError when email invalid', () => {});
    it('should return existing user when duplicate email', () => {});
  });
});
```

---

## Test Structure (AAA Pattern)

```typescript
describe('Calculator', () => {
  describe('add', () => {
    it('should return sum of two positive numbers', () => {
      // Arrange
      const a = 5;
      const b = 3;
      
      // Act
      const result = Calculator.add(a, b);
      
      // Assert
      expect(result).toBe(8);
    });
  });
});
```

---

## Mocking Guidelines

### When to Mock

- ✅ External APIs and services
- ✅ Database (for unit tests)
- ✅ Time-dependent functions
- ✅ File system operations
- ❌ The code under test
- ❌ Simple utilities

### Mock Examples

```typescript
// Mock external service
jest.mock('../services/api');
const mockApi = api as jest.Mocked<typeof api>;
mockApi.fetchUser.mockResolvedValue({ id: '1', name: 'Test' });

// Mock time
jest.useFakeTimers();
jest.setSystemTime(new Date('2024-01-01'));

// Mock environment variable
const originalEnv = process.env;
beforeEach(() => {
  process.env = { ...originalEnv, API_KEY: 'test-key' };
});
afterEach(() => {
  process.env = originalEnv;
});
```

---

## Coverage Requirements

| Metric | Minimum | Target |
|--------|---------|--------|
| Line coverage | 70% | 85% |
| Branch coverage | 60% | 80% |
| Critical paths | 100% | 100% |

### Generating Coverage Report

```bash
yarn test --coverage

# View HTML report
open coverage/lcov-report/index.html
```

---

## Pre-Commit Checklist

Before every commit:

- [ ] All tests pass locally
- [ ] Linter passes with no errors
- [ ] Type check passes
- [ ] New code has tests
- [ ] No `console.log` statements left
- [ ] No `.only` or `.skip` left in tests

---

## CI Pipeline Tests

The CI pipeline runs on every push/PR:

1. **Lint check** - ESLint, Prettier
2. **Type check** - TypeScript compiler
3. **Unit tests** - Fast, isolated tests
4. **Integration tests** - API, database tests
5. **E2E tests** - Full flow tests (main branch only)
6. **Coverage report** - Upload to Codecov

---

## Bug Fix Testing Workflow

When fixing a bug:

1. **FIRST**: Write a failing test that reproduces the bug
2. **THEN**: Fix the bug
3. **VERIFY**: Test now passes
4. **COMMIT**: Include both fix and test

```bash
# Example workflow
# 1. Create failing test
yarn test --watch tests/unit/buggy-function.test.ts

# 2. Fix the code

# 3. Verify test passes
yarn test

# 4. Commit with test
git add .
git commit -m "fix: resolve null handling in parser (#123)

- Added null check in parseInput()
- Added regression test

Closes #123"
```

---

## Common Testing Patterns

### Testing Async Code

```typescript
it('should fetch user data', async () => {
  const user = await userService.getUser('123');
  expect(user.name).toBe('Test User');
});
```

### Testing Errors

```typescript
it('should throw when user not found', async () => {
  await expect(userService.getUser('invalid'))
    .rejects.toThrow('User not found');
});
```

### Testing with Setup/Teardown

```typescript
describe('DatabaseService', () => {
  beforeAll(async () => {
    await db.connect();
  });
  
  afterAll(async () => {
    await db.disconnect();
  });
  
  beforeEach(async () => {
    await db.clear();
  });
  
  // tests...
});
```

---

## Troubleshooting

### Tests Timing Out

```typescript
// Increase timeout for slow tests
it('should complete long operation', async () => {
  // test code
}, 30000); // 30 second timeout
```

### Flaky Tests

- Avoid testing implementation details
- Don't depend on test order
- Mock time-dependent code
- Use `waitFor` for async UI updates

### Memory Leaks

- Clean up subscriptions in `afterEach`
- Close database connections
- Clear intervals/timeouts


---

## MCP AI Tester for UI & E2E Tests

Use the `ai-tester` MCP server to create, run, and debug UI and E2E tests with AI assistance.

### Setting Up MCP for Testing

```bash
# Copy MCP configuration
cp templates/cursor-rules/mcp.json .cursor/mcp.json

# Restart Cursor to load MCP servers
```

### AI-Assisted Test Creation Workflow

1. **Describe the test scenario** to the AI agent
2. **Agent navigates** to your app and interacts with the UI
3. **Agent captures** element selectors and page structure
4. **Agent generates** test code based on observations
5. **Review and refine** the generated tests

### Example Usage

Tell the AI:
> "Use ai-tester to navigate to localhost:3000, test the login flow, 
> and create a test for this scenario"

The AI will:
1. Navigate to the page
2. Capture page state
3. Interact with the UI
4. Generate a test based on the interaction

### Debugging UI Tests with MCP

Ask the AI to:
1. Navigate to the failing test URL
2. Take a screenshot at the failure point
3. Inspect element states
4. Compare expected vs actual UI state
5. Check for JavaScript errors or API issues

### Best Practices for AI-Assisted Testing

| Practice | Why |
|----------|-----|
| Use `data-testid` attributes | More stable than CSS selectors |
| Start dev server before testing | AI needs running app to interact |
| Provide context about expected behavior | Helps AI write better assertions |
| Review generated selectors | AI may need guidance on best selectors |
| Run generated tests locally first | Verify before committing |

### Troubleshooting MCP Testing

| Issue | Solution |
|-------|----------|
| MCP not connecting | Restart Cursor, check MCP server status |
| Page not loading | Ensure dev server is running |
| Selectors not found | Ask AI to re-capture, use data-testid |
| Flaky tests | Add proper waits |

---

## Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Testing Library](https://testing-library.com/docs/)
- [Effective Testing Practices](https://kentcdodds.com/blog/testing)
