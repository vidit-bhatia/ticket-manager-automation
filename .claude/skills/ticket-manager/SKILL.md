---
name: ticket-manager
description: Safely operate the ticket-manager workflow with local gh, git, gstack, and test commands. It requires separate literal human approval and enforces test-before-implementation ordering.
---

# Ticket Manager (Claude Code)

Use this project skill for the repository's ticket-manager workflow. Run local commands directly and report only verifiable output.

## Required configuration

Resolve, and if missing ask for:

- `TICKET_MANAGER_REPO`
- `TICKET_MANAGER_QUERY` (default `is:open label:ready-to-plan`)
- `TICKET_MANAGER_E2E_CMD` (default `npm run test:e2e`)
- `TICKET_MANAGER_E2E_ENV` (default `dev`)
- `DEPLOYMENT_CONFIG_PATH`

Prerequisites: authenticated `gh`, `git`, gstack when creating PR stacks, and the repository test toolchain.

## Safety gates

1. Pick only one issue per invocation.
2. Post the implementation plan as a comment.
3. Stop. A human must reply with a separate comment containing exactly `approved` after trimming whitespace.
4. Verify approval from `gh issue view --json comments`, including comment author and timestamp.
5. Create the test PR only after approval.
6. Wait until the test PR is merged. Verify the merge state.
7. Create the implementation PR only after test PR merge.
8. Merge implementation only after approved reviews, passing required checks, mergeability, and no conflicts.
9. Resolve conflicts or report blockers; never silently discard changes.
10. Update deployment config, run dev E2E, and publish evidence.

## Claude Code commands

```bash
gh issue list --repo "$TICKET_MANAGER_REPO" --search "$TICKET_MANAGER_QUERY" --limit 1 --json number,title,url,body,labels
gh issue view ISSUE_NUMBER --repo "$TICKET_MANAGER_REPO" --json number,title,url,body,labels,comments
gh issue comment ISSUE_NUMBER --repo "$TICKET_MANAGER_REPO" --body-file PLAN_FILE
```

Verify exact approval with comment metadata. Do not use a substring search; normalize body with whitespace trimming and require exact `approved`.

Use gstack for branches and PR work:

```bash
git switch --create "gstack/ticket-ISSUE-test"
# make test changes
gstack push --create-pr
```

After the test PR merge is verified:

```bash
git switch --create "gstack/ticket-ISSUE-impl"
# implement
gstack push --create-pr
gh pr view PR_NUMBER --repo "$TICKET_MANAGER_REPO" --json number,title,state,isDraft,mergeStateStatus,reviewDecision,statusCheckRollup
gh pr merge PR_NUMBER --repo "$TICKET_MANAGER_REPO" --squash
```

Merge only after explicit state verification. Run the configured dev E2E command, retain stdout/stderr and exit code, and update deployment config from the repository changes. Never describe output as success unless the command and exit code prove it.
