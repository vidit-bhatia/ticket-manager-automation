---
name: ticket-manager
description: Safely operate the ticket-manager workflow in GitHub: select one ready ticket, post a final implementation plan, require separate human approval, create PRs in the required order, merge approved work, update deployment configuration, run dev E2E tests, and publish verifiable reports.
---

# Ticket Manager

Use this skill to run one governed stage of the ticket-manager workflow. Never improvise an approval or claim a merge, deployment, or test result without command output.

## Environment and configuration

Before acting, obtain or infer:

- `TICKET_MANAGER_REPO`: GitHub `owner/repo`
- `TICKET_MANAGER_QUERY`: GitHub issue search (default `is:open label:ready-to-plan`)
- `TICKET_MANAGER_E2E_CMD`: dev E2E command (default `npm run test:e2e`)
- `TICKET_MANAGER_E2E_ENV`: target environment (default `dev`)
- `DEPLOYMENT_CONFIG_PATH`: deployment configuration file to update

Do not assume defaults for repository or query when they are sensitive or ambiguous. Ask for missing configuration.

## Desktop tool boundary

Claude Desktop can use this skill only when GitHub access is available through an enabled connector/MCP server or code-execution environment. This package does not contain a GitHub API client or executable tools.

- Never claim GitHub connector operations succeeded unless the connector returned a successful result.
- Never claim local `gh`, `git`, `gstack`, or test commands ran unless code execution returned their output.
- Follow `references/workflow.md` for the complete state machine and evidence rules.

## Workflow summary

1. Pick at most one issue matching the configured query for the current day.
2. Generate the implementation plan and post it as an issue comment.
3. Stop and wait. The final plan must remain in its comment above a separate human comment whose literal normalized body is exactly `approved`.
4. Only after that approval, create the test-case PR.
5. After the test PR is merged, create or update the implementation PR.
6. Merge only an implementation PR that is approved, has passing required checks, and has no merge conflicts.
7. Resolve conflicts only when the resolution is safe and verifiable; otherwise report the exact blocker and stop.
8. Update deployment configuration for the target environment.
9. Run the configured dev E2E command and preserve complete exit status and output.
10. Publish a report that distinguishes merge, configuration, test, deployment, and blocker states.

## Approval rule

The approval comment must be:

- A separate comment below the final plan.
- Authored by a human (not the assistant, a bot, or an automation).
- Literally `approved` after trimming whitespace.

Do not accept words such as "looks good", "lgtm", "approved except...", or approval in a plan comment. Do not infer approval from labels alone. Post no PR-creation action until this exact human comment is verified from issue comment data.

## PR and merge rules

Use gstack for planning and PR stack/branch work. Suggested branch names:

- `gstack/ticket-{issue}-test`
- `gstack/ticket-{issue}-impl`

Before merging, verify required review approval, passing required status checks, mergeability, test PR merge before implementation PR creation, ticket and plan linkage, and explicit authorization for destructive or production changes.

Never merge or deploy because of an ordinary PR comment, CI completion, or label alone.

## Reports

Report only verified facts: action requested; command/API operation and exact result; PR or issue URL; approval author and comment body; merge SHA or merge API output; test command, exit code, and output; deployment configuration changed; blockers and next human action.
