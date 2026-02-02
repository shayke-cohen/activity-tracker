# Sync Templates

## Overview
Sync the latest AI-Native Engineer templates to this project using the MCP server.

## Prerequisites
- `ai-native-engineer` MCP server configured in `.cursor/mcp.json`
- `gh` CLI authenticated

## Steps

1. Call the templates tool to get all templates:
   ```
   templates({ mode: "sync" })
   ```

2. For each template in the response:
   - Read the existing file at `destPath` (if it exists)
   - Check `llmInstructions.action`:
     - `create-if-missing`: Only create if file doesn't exist
     - `overwrite`: Replace the file entirely
     - `merge`: Intelligently merge using `preserve` and `update` hints

3. For merge operations on AGENTS.md:
   - **Preserve** these project-specific sections:
     - Quick Reference Commands
     - Project Overview
     - Tech Stack
     - Project Structure
   - **Update** everything else (workflows, rules, best practices)

4. Write files using your file tools

5. Report summary of changes

## Output

Provide a summary table:

| File | Action | Result |
|------|--------|--------|
| AGENTS.md | merge | Updated workflows section |
| .cursor/rules/security.mdc | overwrite | Updated |
| scripts/setup.sh | create-if-missing | Skipped (exists) |

## Notes
- Commands in `.cursor/commands/` are always overwritten to get latest workflows
- Run this periodically or before starting major work
