# Claude Ticket Manager Quick Start

## Claude Desktop

1. Run `npm run package-claude-skill`.
2. Upload `dist/ticket-manager.skill.zip` in Claude Desktop Settings → Skills/Capabilities.
3. Enable the skill and a GitHub connector/MCP or code-execution environment.
4. Ask for a read-only selection test:

   ```text
   Use ticket-manager for OWNER/REPO with query is:open label:ready-to-plan.
   Pick one ticket and show it. Do not post or modify GitHub.
   ```

The package has no embedded GitHub credentials or tools.

## Claude Code

1. Open Claude Code in this repository.
2. Confirm `.claude/skills/ticket-manager/SKILL.md` is available.
3. Set the repository and test configuration.
4. Ask for a plan-only run:

   ```text
   Use the ticket-manager project skill to pick one ticket and post the implementation plan. Stop before PR creation.
   ```

Claude Code uses local `gh`, `git`, gstack, and test commands.

## Approval

Review the plan in GitHub. A human must post a separate comment:

```text
approved
```

No PR creation occurs until the exact comment is found below the final plan. Words in the plan or conversational approval do not count.

## Stage order

1. One ticket selected.
2. Plan posted.
3. Literal human approval.
4. Test-case PR created.
5. Test PR merged.
6. Implementation PR created.
7. Implementation PR merged.
8. Deployment config updated.
9. Dev E2E run.
10. Evidence report published.
