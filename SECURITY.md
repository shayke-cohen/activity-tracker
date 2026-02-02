# Security Policy

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability, please report it privately:

1. **Email:** security@example.com (replace with actual email)
2. **Subject:** Security Vulnerability Report - [Project Name]
3. **Include:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Any suggested fixes

### What to Expect

- **Acknowledgment:** Within 48 hours
- **Initial Assessment:** Within 1 week
- **Resolution Timeline:** Depends on severity

We will work with you to understand and address the issue promptly.

---

## Security Practices

### For Contributors

#### DO:

- ✅ Use environment variables for secrets
- ✅ Validate all user inputs
- ✅ Use parameterized queries for databases
- ✅ Follow the principle of least privilege
- ✅ Keep dependencies updated
- ✅ Review security advisories

#### DON'T:

- ❌ Commit secrets, API keys, or credentials
- ❌ Disable security features (even in dev)
- ❌ Trust user input without validation
- ❌ Use string concatenation for SQL queries
- ❌ Expose detailed error messages to users
- ❌ Store passwords in plain text

### Secret Management

```bash
# ✅ Good - use environment variables
DATABASE_URL=$DATABASE_URL
API_KEY=$API_KEY

# ❌ Bad - hardcoded secrets
DATABASE_URL=postgresql://user:password@host/db
API_KEY=sk-1234567890abcdef
```

### Files to Never Commit

These should be in `.gitignore`:

- `.env` (except `.env.example`)
- `*.pem`, `*.key`
- `credentials.json`
- `secrets/`
- Any file containing real credentials

---

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| < latest| :x:                |

We recommend always using the latest version.

---

## Security Checklist for PRs

Before approving a PR, verify:

- [ ] No secrets or credentials in code
- [ ] User inputs are validated
- [ ] Database queries are parameterized
- [ ] Authentication/authorization is correct
- [ ] Error messages don't leak sensitive info
- [ ] Dependencies have no known vulnerabilities

---

## Dependencies

### Keeping Updated

```bash
# Check for outdated packages
yarn outdated

# Check for vulnerabilities
yarn audit
```

### Security Advisories

We monitor:
- GitHub Security Advisories
- npm/yarn audit reports
- CVE databases

---

## Incident Response

If a security incident occurs:

1. **Contain** - Limit the impact
2. **Assess** - Understand what happened
3. **Notify** - Inform affected parties
4. **Fix** - Remediate the issue
5. **Review** - Learn and improve

---

## Contact

For security concerns:
- **Email:** security@example.com
- **Response Time:** 48 hours

Thank you for helping keep this project secure!
