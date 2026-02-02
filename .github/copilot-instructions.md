# GitHub Copilot Instructions

This file provides guidance for GitHub Copilot when working on this codebase.

## Project Context

This is an AI-native repository template designed for use with Cursor AI and AI agents.

## Code Style

- Use TypeScript with strict mode
- Follow existing patterns in the codebase
- Use camelCase for variables and functions
- Use PascalCase for classes and types
- Use UPPER_SNAKE_CASE for constants

## Testing

- Write tests for all new functionality
- Use describe/it blocks for test structure
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies

## Documentation

- Add JSDoc comments to functions
- Update README when adding features
- Document breaking changes

## Commit Messages

Follow conventional commits:
- feat: new feature
- fix: bug fix
- docs: documentation
- test: tests
- chore: maintenance

## What NOT to Do

- Don't commit secrets or credentials
- Don't skip tests
- Don't use deprecated patterns
- Don't ignore linter errors
