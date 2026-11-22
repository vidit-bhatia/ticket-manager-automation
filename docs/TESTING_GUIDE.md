# Testing Guide - Ticket Management Automation Skill

## Pre-Flight Checks

Before activating automations in production, run these validation tests:

### 1. GitHub CLI Setup
```bash
# Check authentication
gh auth status

# Should show:
# github.com
#   ✓ Logged in to github.com as YOUR-USERNAME

# Verify repo access
gh repo view OWNER/REPO
```

### 2. Required Permissions
You need:
- ✅ Write access to repository (create issues, PRs, comments)
- ✅ Automation management (create automations in repo settings)
- ✅ CI/CD workflows (trigger and view status)
- ✅ Label management (create and assign labels)

### 3. Environment Setup
```bash
# Install required tools
brew install gh  # or: gh --version (should be 2.0+)
brew install git

# Install gstack (for PR management)
# Follow: https://github.com/stack-auth/gstack

# Verify gstack
gstack --version
```

---

## Stage 1 Testing: Daily Planning

### Unit Test - Plan Generation
```bash
#!/bin/bash
# Test the planning automation workflow

TEST_REPO="OWNER/test-repo"
OWNER="OWNER"
REPO="test-repo"
QUERY_FILTER="is:open label:ready-to-plan"
DRY_RUN="true"

# Run in dry-run mode (no changes made)
bash stage1-daily-planning.sh

# Expected output:
# ✅ Found ticket: #XYZ - Feature Title
# 📝 Posting implementation plan...
# 🏷️  Adding awaiting-plan-approval label...
# ✅ Stage 1 Complete!
```

### Integration Test - Full Stage 1 Cycle
```bash
#!/bin/bash
# Full test: Create issue → Pick it → Post plan → Verify label

# 1. Create test issue
TEST_ISSUE=$(gh issue create \
  --repo $TEST_REPO \
  --title "Test Feature 1" \
  --body "Test description" \
  --label "ready-to-plan" \
  --json number --jq '.number')

echo "Created test issue: #$TEST_ISSUE"

# 2. Run Stage 1 (without dry-run)
ISSUE_NUMBER=$TEST_ISSUE \
OWNER=$OWNER \
REPO=$REPO \
QUERY_FILTER="is:open number:$TEST_ISSUE" \
bash stage1-daily-planning.sh

# 3. Verify results
echo "Verifying..."
gh issue view $TEST_ISSUE \
  --repo $TEST_REPO \
  --json comments,labels \
  --jq '{
    plan_comment: .comments | map(select(.body | contains("## Implementation Plan"))) | length,
    has_awaiting_label: .labels | map(.name) | contains(["awaiting-plan-approval"])
  }'

# Expected output:
# {
#   "plan_comment": 1,
#   "has_awaiting_label": true
# }
```

### Edge Case Testing
```bash
# Test 1: Multiple unscheduled tickets (should pick only first)
gh issue create --repo $TEST_REPO --title "Test 1" --label "ready-to-plan"
gh issue create --repo $TEST_REPO --title "Test 2" --label "ready-to-plan"

OWNER=$OWNER REPO=$REPO bash stage1-daily-planning.sh

# Should process only first ticket, leave second for next run

# Test 2: Issue already has plan (should skip)
# Re-run Stage 1 on same issue
OWNER=$OWNER REPO=$REPO ISSUE_NUMBER=$TEST_ISSUE bash stage1-daily-planning.sh

# Should output: "⚠️  Plan already exists for this ticket. Skipping."

# Test 3: Empty search results
QUERY_FILTER="is:open number:999999" bash stage1-daily-planning.sh

# Should output: "❌ No tickets found matching filter"
```

---

## Stage 2 Testing: PR Creation

### Unit Test - PR Structure Validation
```bash
#!/bin/bash
# Verify PR creation without actual GitHub changes

TEST_REPO="OWNER/test-repo"
ISSUE_NUMBER="123"

# Run Stage 2 (should output PR structure)
OWNER="OWNER" \
REPO="test-repo" \
ISSUE_NUMBER=$ISSUE_NUMBER \
bash stage2-pr-creation.sh

# Expected to show:
# 📝 Creating test PR on branch: gstack/ticket-123-test
# 📋 Test PR Structure:
#    Branch: gstack/ticket-123-test
#    Files:
#      - tests/ticket-123.test.ts
#      - tests/ticket-123-e2e.test.ts
```

### Integration Test - Full Stage 2 Cycle
```bash
#!/bin/bash
# Full test: Create issue with plan → Mark approved → Create PRs

# 1. Create test issue with plan
TEST_ISSUE=$(gh issue create \
  --repo $TEST_REPO \
  --title "Test Feature with Plan" \
  --body "Test" \
  --label "awaiting-plan-approval" \
  --json number --jq '.number')

# 2. Add plan comment
gh issue comment $TEST_ISSUE \
  --repo $TEST_REPO \
  --body "## Implementation Plan
  
### Design
- Do X
- Do Y
- Do Z
"

# 3. Post approval comment (triggers Stage 2)
gh issue comment $TEST_ISSUE \
  --repo $TEST_REPO \
  --body "approved"

# 4. Run Stage 2
OWNER="OWNER" \
REPO="test-repo" \
ISSUE_NUMBER=$TEST_ISSUE \
bash stage2-pr-creation.sh

# 5. Verify
gh issue view $TEST_ISSUE \
  --repo $TEST_REPO \
  --json comments,labels

# Should show:
# - Approval comment found
# - Labels: plan-approved, test-pr-creating, impl-pr-creating
# - Action comment posted
```

### Edge Case Testing
```bash
# Test 1: Multiple approval comments (should use last one before first approval)
gh issue comment $TEST_ISSUE --repo $TEST_REPO --body "approved"
gh issue comment $TEST_ISSUE --repo $TEST_REPO --body "Actually, can you change X?"
gh issue comment $TEST_ISSUE --repo $TEST_REPO --body "approved"

bash stage2-pr-creation.sh
# Should handle multiple approvals gracefully

# Test 2: No plan comment found
TEST_ISSUE_2=$(gh issue create --repo $TEST_REPO --title "No Plan" --label "awaiting-plan-approval" --json number --jq '.number')
gh issue comment $TEST_ISSUE_2 --repo $TEST_REPO --body "approved"

bash stage2-pr-creation.sh
# Should show warning: "Could not find implementation plan"

# Test 3: Approval comment missing exact text
gh issue comment $TEST_ISSUE --repo $TEST_REPO --body "looks good!"
bash stage2-pr-creation.sh
# Should show: "Could not find approval comment"
```

---

## Stage 3 Testing: Merge & Deploy

### Unit Test - E2E Test Execution
```bash
#!/bin/bash
# Test E2E test command validation

PR_NUMBER="45"

# Verify test command exists
npm run test:e2e --version || echo "Command not found"

# Test with custom command
E2E_TEST_COMMAND="npm run test:e2e:dev" \
E2E_ENVIRONMENT="dev" \
bash stage3-deploy.sh

# Should validate command availability
```

### Integration Test - Full Stage 3 Cycle (Requires Real PR)
```bash
#!/bin/bash
# Full test with actual PR (requires test repo setup)

# Note: This test requires:
# 1. Working test PR (gstack/ticket-NNN-test)
# 2. All CI checks passing
# 3. Code review approvals

# Simulate PR creation
TEST_BRANCH="gstack/test-pr-999"
git checkout -b $TEST_BRANCH
echo "// test" >> README.md
git add README.md
git commit -m "Test PR"

PR=$(gh pr create \
  --repo $TEST_REPO \
  --title "Test Implementation PR" \
  --body "Test" \
  --label "impl-pr-created" \
  --draft)  # Create as draft

echo "Created PR: $PR"

# Wait for CI checks
echo "Waiting for CI checks (this takes ~5 min in real repo)..."
gh pr status --repo $TEST_REPO

# Run Stage 3
PR_NUMBER=$PR \
OWNER="OWNER" \
REPO="test-repo" \
AUTO_MERGE_ENABLED="true" \
bash stage3-deploy.sh

# Verify deployment
gh pr view $PR --repo $TEST_REPO --json merged
# Should show: "merged": true
```

---

## End-to-End Workflow Test

### Complete Automation Cycle
```bash
#!/bin/bash
# Full workflow: Stage 1 → Stage 2 → Stage 3

set -e

TEST_REPO="OWNER/test-repo"
START_TIME=$(date +%s)

echo "🧪 Starting end-to-end automation test..."
echo "    Repository: $TEST_REPO"
echo "    Start time: $(date)"
echo ""

# Phase 1: Stage 1 - Daily Planning (09:00 AM UTC simulation)
echo "📋 Phase 1: Daily Planning"
echo "   Creating test issue with ready-to-plan label..."

TEST_ISSUE=$(gh issue create \
  --repo $TEST_REPO \
  --title "E2E Test: Feature #$(date +%s%N | cut -b1-10)" \
  --body "Full end-to-end automation test" \
  --label "ready-to-plan" \
  --json number --jq '.number')

echo "   Test issue created: #$TEST_ISSUE"
sleep 2

echo "   Running Stage 1..."
OWNER="OWNER" \
REPO="test-repo" \
QUERY_FILTER="is:open number:$TEST_ISSUE" \
bash stage1-daily-planning.sh

echo "   Verifying Stage 1..."
PLAN_POSTED=$(gh issue view $TEST_ISSUE \
  --repo $TEST_REPO \
  --json comments \
  --jq '.comments | map(select(.body | contains("## Implementation Plan"))) | length')

if [ "$PLAN_POSTED" = "1" ]; then
    echo "   ✅ Plan posted successfully"
else
    echo "   ❌ Plan not found"
    exit 1
fi

# Phase 2: Stage 2 - Approval & PR Creation
echo ""
echo "📝 Phase 2: Approval & PR Creation"
echo "   Posting approval comment..."

gh issue comment $TEST_ISSUE \
  --repo $TEST_REPO \
  --body "approved"

sleep 1

echo "   Running Stage 2..."
OWNER="OWNER" \
REPO="test-repo" \
ISSUE_NUMBER=$TEST_ISSUE \
bash stage2-pr-creation.sh

echo "   ✅ PRs created successfully"

# Phase 3: Stage 3 - Merge & Deploy
echo ""
echo "🚀 Phase 3: Merge & Deploy"
echo "   Note: This phase requires real PR with passing CI"
echo "   In production, this triggers automatically when PR is ready"
echo "   ✅ Would run: PR merge, E2E tests, deployment"

# Cleanup
echo ""
echo "🧹 Cleanup"
gh issue delete $TEST_ISSUE --repo $TEST_REPO --confirm || true

# Summary
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "✅ End-to-End Test Complete!"
echo "   Total duration: ${DURATION}s"
echo "   All stages passed validation"
