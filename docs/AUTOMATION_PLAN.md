# Daily Ticket Management Automation Skill

## Overview
A configurable GitHub Copilot Automation system that acts like a junior engineer, processing tickets through a 3-stage workflow: Planning → Testing → Implementation → Merge & Deploy.

## Architecture

### Stage 1: Daily Ticket Selection & Planning
**Trigger:** Daily at 09:00 UTC (configurable per schedule)
**Input Parameters (configurable per schedule):**
- `owner`: Repository owner
- `repo`: Repository name  
- `query_filter`: GitHub query to find tickets (e.g., `is:open label:ready-to-plan`)
- `dry_run`: Boolean to preview without taking action

**Workflow:**
1. Query GitHub issues using provided filter
2. Pick first unscheduled ticket
3. Generate implementation plan using Claude
4. Post plan as GitHub issue comment
5. Add label `awaiting-plan-approval`
6. Wait for user approval (comment: "approved")

**Output:** 
- Issue labeled with `awaiting-plan-approval`
- Implementation plan in comment thread

---

### Stage 2: Test Cases & Implementation PR
**Trigger:** When issue receives "approved" comment AND has label `awaiting-plan-approval`
**Prerequisites:** 
- Plan must be approved (comment with "approved")
- Test case PR must be merged (checked before impl PR creation)

**Workflow:**
1. Find approved issue without `implementation-in-progress` label
2. Extract plan from last comment before "approved"
3. Generate test cases based on plan
4. Create test PR with branch: `gstack/ticket-{number}-test`
   - Add test file(s) in `tests/` or `__tests__/`
   - Add test scenario documentation
5. Create implementation PR with branch: `gstack/ticket-{number}-impl`
   - Implementation code
   - Configuration updates (deployment, env, etc.)
   - Link to test PR in description
6. Run test suite on test PR
7. Wait for test PR merge before merging impl PR

**Output:**
- Test PR created and linked in issue
- Implementation PR created (draft if tests failing)
- Issue labels: `test-pr-created`, `impl-pr-created`

---

### Stage 3: Merge, Deploy & E2E Testing
**Trigger:** When implementation PR is ready to merge (all checks green)
**Prerequisites:**
- Test PR merged
- All CI checks passing
- Code review approved (1+ approvals)

**Workflow:**
1. Find approved impl PRs with passing checks
2. Auto-merge PR (resolve conflicts if necessary)
3. Verify deployment configuration updated
4. Create deployment PR if needed
5. Run E2E test suite against dev environment
6. Generate E2E test report
7. Post results as GitHub comment
8. Add label `deployed` to issue

**Output:**
- PR merged
- E2E tests run against dev environment
- Report generated and posted
- Issue labeled: `deployed`, `e2e-tested`

---

## Configuration & Scheduling

### Automation 1: Daily Planning Automation
```yaml
Name: "Ticket Daily Planning"
Trigger: 
  - type: "interval"
    hour_utc: 9  # 09:00 UTC daily
    minute_utc: 0
Configurable Parameters:
  - owner (string): repo owner
  - repo (string): repo name
  - query_filter (string): issue query
  - dry_run (boolean): preview only
```

### Automation 2: Approval & Test PR Automation
```yaml
Name: "Ticket Plan Approved - Create Tests & Impl"
Trigger:
  - type: "issues"  
    types: ["commented"]
    comment_types: ["issue_comment"]
    body_substring: "approved"
Configurable Parameters:
  - auto_merge_tests (boolean): auto-merge test PRs
  - deployment_config_path (string): path to deployment config
```

### Automation 3: Merge & Deploy Automation
```yaml
Name: "Ticket Ready - Merge & Deploy"
Trigger:
  - type: "pull_requests"
    types: ["review_requested", "ready_for_review"]
    labels: ["impl-pr-created"]
Configurable Parameters:
  - auto_merge_enabled (boolean)
  - e2e_test_command (string): command to run E2E tests
  - e2e_environment (string): dev/staging/prod
```

---

## Tools Required

### GitHub MCP Server Tools:
- `create_automation` - Create the 3 automations
- `list_automations` - View all automations
- `run_automation` - Manually trigger a workflow
- `update_automation` - Modify automation settings
- `create_automation_group` - Group related automations

### GitHub CLI (via bash):
- `gh issue list` - Query issues
- `gh issue comment` - Add comments
- `gh pr create` - Create pull requests
- `gh pr merge` - Merge PRs
- `gh label` - Manage labels

### Additional Tools:
- Claude API - Generate plans, test cases
- gstack - Git stack management for PR chains

---

## State Management

### Issue Labels Used:
- `awaiting-plan-approval` - Plan posted, waiting for approval
- `plan-approved` - Plan approved by user
- `test-pr-created` - Test PR created
- `impl-pr-created` - Implementation PR created
- `implementation-in-progress` - Implementation started
- `e2e-testing` - E2E tests running
- `deployed` - Successfully deployed to dev
- `e2e-tested` - E2E tests completed and passed

### PR Naming Convention:
- Test PR: `gstack/ticket-{issue-number}-test`
- Implementation PR: `gstack/ticket-{issue-number}-impl`
- Deployment PR: `gstack/ticket-{issue-number}-deploy`

---

## User Workflow

1. **Day 1 (09:00 AM):** Automation picks ticket, posts plan, waits for approval
2. **Day 1 (During day):** User reviews plan in issue comment thread, approves with comment
3. **Day 1 (Trigger on approval):** Test PR and Impl PR created automatically
4. **Day 2-3:** User reviews and merges test PR (all tests must pass first)
5. **Day 3-4:** Implementation PR reviewed and approved by maintainers
6. **On approval:** Automation merges impl PR, runs E2E tests, generates report
7. **Within minutes:** Issue marked as deployed with E2E report

---

## Success Criteria

✅ Automation picks one ticket daily  
✅ Plan created and posted for user review  
✅ User can improve plan via comments before "approved"  
✅ Test PR created with comprehensive test scenarios  
✅ Implementation PR created with all updates  
✅ All tests pass before deployment  
✅ E2E tests run against dev environment  
✅ Conflict resolution automatic when possible  
✅ Reports generated and posted to issue  
✅ Fully configurable per repository  
✅ Can be scheduled to run on any configured repo  
✅ Acts as junior engineer - follows best practices  
