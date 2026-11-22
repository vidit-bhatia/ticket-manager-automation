# Claude Skill Deployment

This repository has two real Claude integrations and one unrelated GitHub Copilot integration:

- **Claude Desktop:** `skills/ticket-manager/SKILL.md`, packaged for upload.
- **Claude Code:** `.claude/skills/ticket-manager/SKILL.md`, loaded as a project skill.
- **GitHub Copilot:** `.github/extensions/ticket-manager-automation/extension.mjs`. This is not a Claude skill.

## Package for Claude Desktop

Create the ZIP:

```bash
npm run package:claude-skill
```

The result is `dist/ticket-manager.skill.zip`. It contains:

```text
ticket-manager/
├── SKILL.md
└── references/
    └── workflow.md
```

Validate locally:

```bash
unzip -t dist/ticket-manager.skill.zip
unzip -l dist/ticket-manager.skill.zip
```

Do not commit generated ZIP files unless a release intentionally publishes the binary artifact.

## Install in Claude Desktop

1. Open Claude Desktop Settings.
2. Open Skills or Skills/Capabilities.
3. Choose the custom-skill upload/add action and select `dist/ticket-manager.skill.zip`.
4. Enable the skill for the conversations where it should be used.
5. Configure or enable an approved GitHub connector/MCP server or code-execution capability before asking it to perform GitHub operations.

The ZIP contains instructions only. It does not bundle a GitHub API client or unsupported fake tools.

## Test in Claude Desktop

Start with a read-only request:

```text
Use the ticket-manager skill for OWNER/REPO with query
is:open label:ready-to-plan. Pick one ticket and show the selection,
but do not post comments or create branches or PRs.
```

Then test a plan-only request:

```text
Generate and post the implementation plan for ISSUE_NUMBER in OWNER/REPO.
Do not create a PR or interpret my conversation as approval.
```

After review, post `approved` as a separate human comment on GitHub. Only that comment can authorize test-PR creation.

## Install in Claude Code

The project skill is already at `.claude/skills/ticket-manager/SKILL.md`. Open Claude Code in the repository root and verify that project skills are enabled.

Configure:

```bash
export TICKET_MANAGER_REPO="owner/repo"
export TICKET_MANAGER_QUERY="is:open label:ready-to-plan"
export TICKET_MANAGER_E2E_CMD="npm run test:e2e"
export TICKET_MANAGER_E2E_ENV="dev"
export DEPLOYMENT_CONFIG_PATH="config/deployment.yaml"
gh auth status
git --version
gstack --version
```

Test with a plan-only prompt:

```text
Use the ticket-manager project skill. Pick one ticket and post only the implementation plan. Stop before PR creation.
```

## Required workflow gates

- The final plan must be above a separate human comment whose exact trimmed body is `approved`.
- The test-case PR is created only after exact human approval.
- The implementation PR is created only after the test PR merge is verified.
- Merge and deploy operations require explicit verification of approvals, checks, mergeability, and command/API output.
- gstack is used for PR and branch stack work.
- Conflict resolution is explicit; unresolved conflicts are reported as blockers.
- Deployment configuration is updated before dev E2E.
- E2E success is reported only with exit code and output evidence.

## Limitations

Claude Desktop cannot directly execute repository-local shell commands unless code execution is available. GitHub operations require connector/MCP or code execution; skill packaging alone grants no credentials or permissions.
