# Contributing Guide

Thank you for your interest in contributing to this project!

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)

---

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to maintain a welcoming environment for all contributors.

---

## Getting Started

### Prerequisites

- Node.js 20.x LTS
- Yarn 4.x
- GitHub CLI (`gh`)
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/owner/repo.git
cd repo

# Install dependencies
yarn install

# Copy environment template
cp .env.example .env

# Run setup
./scripts/setup.sh
```

### Verify Setup

```bash
./scripts/verify-setup.sh
```

---

## Development Workflow

### 1. Find or Create an Issue

- Browse [existing issues](https://github.com/owner/repo/issues)
- Create a new issue if one doesn't exist
- Wait for issue to be triaged/approved before starting work

### 2. Start Work

```bash
# Using our workflow script (recommended)
./scripts/start-issue.sh <issue-number>

# Or manually
git checkout -b feature/issue-<number>-description
```

### 3. Make Changes

- Follow the coding standards in [AGENTS.md](./AGENTS.md)
- Write tests for new functionality
- Keep commits focused and well-described

### 4. Test Your Changes

```bash
# Run all checks
yarn lint
yarn typecheck
yarn test
```

### 5. Submit Pull Request

```bash
# Using our workflow script
./scripts/finish-issue.sh <issue-number>

# Or manually
git push -u origin feature/issue-<number>-description
gh pr create
```

---

## Pull Request Process

### Before Submitting

- [ ] All tests pass
- [ ] Linting passes
- [ ] Code is documented
- [ ] PR description explains changes
- [ ] Issue number is referenced

### PR Template

Your PR should include:

1. **Summary** - What does this PR do?
2. **Related Issues** - Link to issue(s) this addresses
3. **Changes Made** - List of specific changes
4. **Testing** - How was this tested?
5. **Screenshots** - Required for UI changes (see [Screenshot Guidelines](./AGENTS.md#screenshot-guidelines))

### Review Process

1. Automated checks run (CI)
2. Maintainer reviews code
3. Address any feedback
4. PR is merged when approved

### After Merge

- Delete your branch
- Close related issue (if not auto-closed)
- Update documentation if needed
- Add to `knowledge/LESSONS_LEARNED.md` if you learned something valuable

---

## Code Style

### General Guidelines

- Follow existing patterns in the codebase
- Write self-documenting code
- Add comments for complex logic
- Keep functions small and focused

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `user-service.ts` |
| Variables | camelCase | `userName` |
| Functions | camelCase | `getUserById()` |
| Classes | PascalCase | `UserService` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Code restructuring
- `test` - Adding tests
- `chore` - Maintenance

**Examples:**
```
feat(auth): add password reset flow
fix(api): handle null response
docs(readme): update installation steps
```

---

## Testing

### Requirements

- All new features must have tests
- All bug fixes must have regression tests
- Coverage should not decrease

### Running Tests

```bash
# All tests
yarn test

# With coverage
yarn test --coverage

# Watch mode
yarn test --watch

# Specific file
yarn test path/to/test.ts
```

### Writing Tests

```typescript
describe('FeatureName', () => {
  describe('methodName', () => {
    it('should do something when condition', () => {
      // Arrange
      const input = {};
      
      // Act
      const result = method(input);
      
      // Assert
      expect(result).toBe(expected);
    });
  });
});
```

---

## Documentation

### When to Update Docs

- Adding new features → Update README, API docs
- Changing behavior → Update relevant docs
- Adding configuration → Update setup docs
- Learning something → Add to knowledge/

### Documentation Files

| File | Purpose |
|------|---------|
| README.md | User-facing overview |
| AGENTS.md | AI agent instructions |
| ARCHITECTURE.md | System design |
| STACK.md | Tech stack decisions |
| TESTING.md | Testing guide |
| knowledge/*.md | Institutional memory |

---

## Questions?

- Check existing documentation
- Search closed issues
- Open a discussion or issue

---

Thank you for contributing! 🎉
