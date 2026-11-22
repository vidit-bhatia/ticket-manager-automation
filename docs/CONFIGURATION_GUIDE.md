# Ticket Management Automation Skill - Configuration Guide

## Quick Start

### Prerequisites
- GitHub repository with write access
- GitHub CLI (`gh`) installed and authenticated
- gstack installed (for PR stack management)
- Automation enabled in repository settings

### Step 1: Create Required Labels

Run this once per repository:

```bash
gh label create awaiting-plan-approval --repo OWNER/REPO --description "Plan posted, waiting for user approval"
gh label create plan-approved --repo OWNER/REPO --description "Plan has been approved by user"
gh label create test-pr-created --repo OWNER/REPO --description "Test PR created"
gh label create impl-pr-created --repo OWNER/REPO --description "Implementation PR created"
gh label create implementation-in-progress --repo OWNER/REPO --description "Implementation is in progress"
gh label create e2e-testing --repo OWNER/REPO --description "E2E tests are running"
gh label create deployed --repo OWNER/REPO --description "Successfully deployed to dev"
gh label create e2e-tested --repo OWNER/REPO --description "E2E tests completed and passed"
gh label create ready-to-plan --repo OWNER/REPO --description "Ready for daily planning automation to pick up"
```

### Step 2: Mark Issues as Ready

Add the `ready-to-plan` label to issues you want the automation to process:

```bash
gh issue edit ISSUE_NUMBER --repo OWNER/REPO --add-label ready-to-plan
```

## Automation Configurations

### Automation 1: Daily Ticket Planning (Scheduled)

**Type:** Scheduled (Interval)  
**Trigger:** Every day at 09:00 UTC  
**What it does:** Picks one ticket daily, generates plan, posts as comment, waits for approval

**Parameters:**
```
OWNER=your-org
REPO=your-repo
QUERY_FILTER=is:open label:ready-to-plan
DRY_RUN=false
```

**How to Create via GitHub CLI:**

```bash
gh api graphql -f query='
mutation {
  createAutomation(
    input: {
      ownerId: "YOUR_USER_ID"
      name: "Daily Ticket Planning"
      description: "Pick one ticket daily, generate plan"
      prompt: "Run the daily ticket planning automation..."
      triggers: {
        interval: {
          hourUtc: 9
          minuteUtc: 0
        }
      }
    }
  ) {
    automation {
      id
      name
    }
  }
}
'
```

**Or use the GitHub UI:**
1. Go to Repository Settings → Automations
2. Click "Create Automation"
3. Fill in:
   - **Name:** "Daily Ticket Planning"
   - **Trigger:** Scheduled (Daily at 09:00 UTC)
   - **Prompt:** See below

**Prompt for Automation 1:**
```
You are a junior engineer managing daily ticket planning.

Configuration:
- Repository: {owner}/{repo}
- Query Filter: {query_filter}

Task:
1. Use `gh issue list` to find tickets matching the filter
2. Pick the first ticket without a plan comment
3. Generate a comprehensive implementation plan
4. Post the plan as a GitHub issue comment
5. Add the label "awaiting-plan-approval"
6. Wait for user approval (comment: "approved")

Use gstack for creating any PR stacks.
Ensure all configuration updates are tracked.
```

---

### Automation 2: Approval Trigger (Event-based)

**Type:** Event Trigger  
**Trigger:** When issue receives comment with "approved"  
**What it does:** Creates test PR and implementation PR when plan is approved

**Triggers Configuration:**
```json
{
  "types": ["commented"],
  "comment_types": ["issue_comment"],
  "body_substring": "approved"
}
```

**Parameters:**
```
OWNER=your-org
REPO=your-repo
AUTO_MERGE_TESTS=false
DEPLOYMENT_CONFIG_PATH=config/deployment.yaml
```

**Prompt for Automation 2:**
```
You are a junior engineer creating test and implementation PRs.

Configuration:
- Repository: {owner}/{repo}
- Auto-merge tests: {auto_merge_tests}
- Deployment config: {deployment_config_path}

Task:
1. When this triggers on a comment with "approved":
   - Extract the approval comment
   - Retrieve the implementation plan from the issue
2. Create test PR on branch: gstack/ticket-{issue-number}-test
   - Add comprehensive test cases
   - Create E2E test scenarios
3. Create implementation PR on branch: gstack/ticket-{issue-number}-impl
   - Implementation code
   - Configuration updates
   - Deployment config changes
4. Update issue labels and post status comment
5. Use gstack for PR stacks

Ensure tests pass before proceeding to merge.
```

---

### Automation 3: Ready to Merge (Event-based)

**Type:** Event Trigger  
**Trigger:** When implementation PR is ready (all checks green)  
**What it does:** Merges PR, runs E2E tests, generates report

**Triggers Configuration:**
```json
{
  "types": ["ready_for_review", "review_requested"],
  "labels": ["impl-pr-created"],
  "conclusions": ["success"]
}
```

**Parameters:**
```
OWNER=your-org
REPO=your-repo
AUTO_MERGE_ENABLED=true
E2E_TEST_COMMAND=npm run test:e2e
E2E_ENVIRONMENT=dev
```

**Prompt for Automation 3:**
```
You are a junior engineer handling PR merges and deployment.

Configuration:
- Repository: {owner}/{repo}
- Auto-merge: {auto_merge_enabled}
- E2E test command: {e2e_test_command}
- Target environment: {e2e_environment}

Task:
1. When this triggers on a ready implementation PR:
   - Verify all CI checks are passing
   - Check that test PR is merged
2. Merge the implementation PR
   - Resolve any conflicts if necessary
   - Use squash or merge strategy as configured
3. Run E2E tests against {e2e_environment}
   - Execute: {e2e_test_command}
   - Collect results and coverage
4. Generate E2E test report with:
   - Test results (passed/failed)
   - Coverage percentages
   - Performance metrics
5. Update original issue with:
   - Deployment status
   - E2E test report
   - Labels: deployed, e2e-tested
6. Post deployment summary comment

Ensure all tests pass before marking as deployed.
```

---

## Example Workflow

### Day 1: 09:00 AM
**Automation 1 runs (Daily Planning)**
```
Issue #42 found with label "ready-to-plan"
↓
Plan generated and posted
↓
Issue labeled: "awaiting-plan-approval"
↓
Waiting for user approval...
```

**User reviews plan in browser**
```
User reads plan in issue comments
User discusses with AI (optional)
Final plan is established
User comments: "approved"
```

### Day 1: Afternoon
**Automation 2 runs (Approval Trigger)**
```
Issue #42 receives comment "approved"
↓
Test PR created: gstack/42-test
Implementation PR created: gstack/42-impl
↓
Issue labels updated: plan-approved, test-pr-created, impl-pr-created
↓
Status comment posted
```

**Testing phase**
```
Test PR runs CI pipeline
Tests must pass (100% green)
Reviewer merges test PR
↓
Implementation PR can proceed
```

### Day 2-3: Code Review
**Manual review**
```
Maintainers review implementation PR
Request changes if needed
Approve when ready
```

### Day 3-4: Deployment
**Automation 3 runs (Ready to Merge)**
```
Implementation PR has passing checks + approvals
↓
PR automatically merged
↓
E2E tests run against dev environment
↓
Report generated and posted
↓
Issue labeled: deployed, e2e-tested
↓
Feature is ready for production
```

---

## Customization

### Change Daily Planning Time
In Automation 1 trigger configuration:
```json
{
  "interval": {
    "hourUtc": 14,  // 2 PM UTC
    "minuteUtc": 30 // 30 minutes
  }
}
```

### Use Custom Query Filter
Examples:
```
# Only features
is:open label:feature,ready-to-plan

# Only bugs with priority
is:open label:bug,ready-to-plan priority:critical

# Assigned to specific user
is:open assignee:@me label:ready-to-plan

# Custom milestone
is:open milestone:v2.0 label:ready-to-plan
```

### Configure E2E Test Environment
```bash
# Update parameter when creating automation
E2E_ENVIRONMENT=staging  # or production, etc.
E2E_TEST_COMMAND="npm run test:e2e:staging"
```

### Auto-merge Strategy
```
# Squash merge (recommended for clean history)
gh pr merge $PR_NUMBER --squash

# Regular merge (preserves commits)
gh pr merge $PR_NUMBER --merge

# Rebase and merge
gh pr merge $PR_NUMBER --rebase
```

---

## Troubleshooting

### Automation Not Running
1. Check if automations are enabled in repository settings
2. Verify authentication: `gh auth status`
3. Ensure labels exist: `gh label list --repo OWNER/REPO`

### Plan Not Being Approved
1. Check issue comment history: `gh issue view ISSUE_NUMBER --repo OWNER/REPO --json comments`
2. Ensure comment contains exact string "approved"
3. Try re-commenting if case-sensitive matching is an issue

### E2E Tests Failing
1. Check if environment is running: `curl $E2E_URL`
2. Verify test command is correct: `npm run test:e2e`
3. Review test logs for specific failures
4. Check if deployment config is properly applied

### Merge Conflicts
1. Automation will halt on conflicts
2. Manual intervention required:
   ```bash
   git fetch origin
   git checkout gstack/ticket-NNN-impl
   git rebase origin/main  # or merge
   # Resolve conflicts
   git push --force-with-lease
   ```

---

## Monitoring & Reporting

### View All Automations
```bash
gh api repos/{owner}/{repo}/automations --jq '.automations[] | {id, name, enabled}'
```

### Check Automation Logs
```bash
gh api repos/{owner}/{repo}/automations/{automation-id}/runs \
  --jq '.runs[] | {id, status, createdAt}'
```

### Generate Weekly Report
```bash
gh issue list --repo OWNER/REPO --label deployed --jq \
  '.[] | {number, title, closed_at, labels}' | jq -s 'length'
```

---

## Best Practices

✅ **DO:**
- Test automations in a staging repo first
- Review generated plans before marking approved
- Use descriptive query filters
- Keep deployment config in version control
- Monitor E2E test reports
- Use labels consistently

❌ **DON'T:**
- Run multiple automation instances on same ticket
- Skip E2E tests for critical features
- Auto-merge without tests passing
- Change query filter mid-week
- Disable automations without notifying team

---

## Support & Extensions

### Adding Custom Analysis
Modify Stage 2 prompt to include:
```
Before creating PRs:
1. Run static analysis (ESLint, etc.)
2. Check test coverage requirements
3. Validate deployment config syntax
```

### Integration with Slack
Add at end of Stage 3:
```
gh issue comment ISSUE_NUMBER --body "
:rocket: Deployment complete!
Slack message sent to #deployments channel
"
```

### Database Migration Support
In Stage 2, add check:
```
if [ -f "db/migrations/new_migration.sql" ]; then
  # Validate migration syntax
  # Add migration PR if needed
fi
```
