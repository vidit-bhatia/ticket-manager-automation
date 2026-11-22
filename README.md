# Ticket Manager Automation

Ticket Manager provides a staged workflow for selecting one GitHub ticket, producing an implementation plan, creating test and implementation pull requests, merging approved work, updating deployment configuration, running dev E2E tests, and publishing a report.

This repository supports three distinct integrations:

| Integration | Location | GitHub access |
|---|---|---|
| Claude Desktop | `skills/ticket-manager/SKILL.md` | Connector/MCP or code execution must be enabled separately |
| Claude Code | `.claude/skills/ticket-manager/SKILL.md` | Local authenticated `gh`, `git`, and gstack |
| GitHub Copilot automation | `.github/extensions/ticket-manager-automation/extension.mjs` | GitHub Copilot extension environment |

The Claude packages are not GitHub Copilot extensions. `.github/extensions/.mjs` is a GitHub Copilot extension and is not an Agent Skill.

## Safety and approval workflow

The workflow never auto-approves or creates PRs from a plan alone:

1. Pick one ticket from `TICKET_MANAGER_REPO` using `TICKET_MANAGER_QUERY`.
2. Post the final implementation plan in a comment.
3. Wait for a **separate human comment** whose body, after trimming whitespace, is exactly `approved`.
4. Create the test-case PR only after that comment is verified.
5. Merge the test PR and verify the merge.
6. Create the implementation PR only after test PR merge.
7. Merge only an implementation PR with required approvals, passing checks, and no conflicts.
8. Update deployment configuration, run the configured dev E2E command, and publish a report.

Use gstack for planning and PR stack work. Never claim a merge, deployment, or passing test without verifiable command or API output. Resolve conflicts explicitly or report the blocker.

## Claude Desktop install

1. Package the skill:

   ```bash
   npm run package:claude-skill
   ```

2. Confirm that `dist/ticket-manager.skill.zip` contains a top-level `ticket-manager/` folder with `SKILL.md` and `references/workflow.md`.
3. In Claude Desktop, open Settings, then the Skills or Skills/Capabilities section, and add/upload the ZIP as a custom skill.
4. Enable the skill for conversations where it should be available.
5. Enable a GitHub connector/MCP server and/or code execution only if you want GitHub operations. The ZIP itself provides instructions, not a fake GitHub tool.
6. Test with:

   ```text
   Use the ticket-manager skill. In repository OWNER/REPO, search with is:open label:ready-to-plan and select one ticket for planning. Do not create PRs.
   ```

Claude Desktop operations depend on connector, MCP, or code-execution availability. It cannot use local repository files or `gh` by default.

## Claude Code install

1. Clone or open this repository.
2. Copy or maintain the project skill at `.claude/skills/ticket-manager/SKILL.md`.
3. Authenticate local tools:

   ```bash
   gh auth status
   git --version
   gstack --version
   ```

4. Configure environment variables:

   ```bash
   export TICKET_MANAGER_REPO="owner/repo"
   export TICKET_MANAGER_QUERY="is:open label:ready-to-plan"
   export TICKET_MANAGER_E2E_CMD="npm run test:e2e"
   export TICKET_MANAGER_E2E_ENV="dev"
   export DEPLOYMENT_CONFIG_PATH="config/deployment.yaml"
   ```

5. Start Claude Code in the repository and ask:

   ```text
   Use the ticket-manager project skill to pick one ticket and post only the implementation plan. Stop before PR creation.
   ```

Claude Code uses local `gh`, `git`, gstack, and test commands directly. It still requires the exact human approval comment and test-PR merge gates.

## ZIP structure

```text
ticket-manager.skill.zip
└── ticket-manager/
    ├── SKILL.md
    └── references/
        └── workflow.md
```

Generated ZIPs are ignored under `dist/` and should not be committed unless a release workflow intentionally requires a binary artifact.

## Configuration

| Setting | Environment variable | Default |
|---|---|---|
| Repository | `TICKET_MANAGER_REPO` | none |
| Ticket query | `TICKET_MANAGER_QUERY` | `is:open label:ready-to-plan` |
| Dev E2E command | `TICKET_MANAGER_E2E_CMD` | `npm run test:e2e` |
| Environment | `TICKET_MANAGER_E2E_ENV` | `dev` |
| Deployment config | `DEPLOYMENT_CONFIG_PATH` | repository-defined |

## Existing automation scripts

The stage scripts remain available for local or GitHub automation use:

- `scripts/stage1-daily-planning.sh`
- `scripts/stage2-pr-creation.sh`
- `scripts/stage3-deploy.sh`

Run scripts only with deliberate configuration and review their output. They do not replace the Claude skill's approval and evidence checks.

## Documentation

- [Claude skill deployment](docs/CLAUDE_SKILL_DEPLOYMENT.md)
- [Claude quick start](docs/CLAUDE_SKILL_QUICK_START.md)
- [Automation plan](docs/AUTOMATION_PLAN.md)
- [Configuration guide](docs/CONFIGURATION_GUIDE.md)
- [Testing guide](docs/TESTING_GUIDE.md)

## Limitations

- Claude Desktop needs separately enabled GitHub/terminal capabilities.
- Approval is verified only from comment data and never inferred from labels or conversational text.
- The implementation PR cannot be created until the test PR merge is verified.
- Protected branches may require manual review or merge.
- Merge conflicts require safe resolution or a human blocker report.
- A successful deployment cannot be claimed until command/API evidence is available.

## License

MIT
