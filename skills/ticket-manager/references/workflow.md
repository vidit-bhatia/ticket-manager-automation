# Ticket Manager Workflow Reference

## Stage gates

### 1. Select

Run issue search once per invocation:

```text
repo:<owner>/<repo> <TICKET_MANAGER_QUERY>
```

Select at most one open issue. Exclude issues already associated with a plan or active PR unless the user explicitly resumes that ticket.

### 2. Plan

Fetch the issue title, body, labels, comments, assignees, linked PRs, and acceptance criteria. Produce objective, scope, desired behavior, files/packages likely to change, implementation steps, test cases, deployment config changes, risks, rollback, and required verification evidence.

Post the plan as one final comment. Do not append `approved` to that comment. Apply or report `awaiting-plan-approval` without creating PRs.

### 3. Verify approval

Fetch comments in chronological order. Locate a comment whose `body.trim()` equals `approved` and whose timestamp is after the final plan comment.

Confirm the author is a human. If author identity cannot be verified, stop. Never treat the skill's own or an automation's comment as approval.

### 4. Test PR

After exact approval, use gstack to create `gstack/ticket-{issue}-test`, add test-only changes, open a PR, and report its URL and branch. Do not create or start the implementation PR in this stage.

### 5. Test merge, then implementation PR

Wait for the test PR to be merged and verify merge output or merged state. Only then use gstack to create `gstack/ticket-{issue}-impl`. Link it to the merged test PR and approved plan.

### 6. Merge and deploy

Stop if the implementation PR is not mergeable, required checks are pending/failing, required approvals are missing, or conflicts exist.

Resolve conflicts only safely with exact commands and rerun tests. Otherwise report the blocker and stop.

Capture merge command/API call, exit status, merge SHA when returned, and deletion status. Update deployment configuration and run the configured dev E2E command. Capture stdout/stderr and exit code; failure is not success.

### 7. Report

```markdown
## Ticket Manager Report
- Ticket:
- Plan comment:
- Human approval:
- Test PR:
- Test PR merged:
- Implementation PR:
- Merge verification:
- Deployment config:
- Dev E2E command:
- Dev E2E exit code:
- Dev E2E evidence:
- Deployment status:
- Blockers:
- Next human action:
```
