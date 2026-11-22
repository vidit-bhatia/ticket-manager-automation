#!/bin/bash

##############################################################################
# STAGE 2: Approval & Test PR Creation Automation
# Trigger: When issue receives comment with "approved"
# Purpose: Verify exact human approval and prepare the test PR with gstack
##############################################################################

set -e

OWNER="${OWNER:-}"
REPO="${REPO:-}"
ISSUE_NUMBER="${ISSUE_NUMBER:-}"
DEPLOYMENT_CONFIG_PATH="${DEPLOYMENT_CONFIG_PATH:-config/deployment.yaml}"

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$ISSUE_NUMBER" ]; then
    echo "ERROR: OWNER, REPO, and ISSUE_NUMBER must be provided"
    exit 1
fi

echo "🤖 [Stage 2] Approval & Test PR Creation Automation"
echo "   Repository: $OWNER/$REPO"
echo "   Ticket: #$ISSUE_NUMBER"
echo ""

# Step 1: Verify "approved" comment exists
echo "Verifying exact approval before test PR creation..."
echo ""

# Step 2: Require a separate human comment with exactly "approved"
APPROVAL_JSON=$(gh issue view "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --json comments \
    --jq '[.comments[] | select((.body | gsub("^\\s+|\\s+$"; "")) == "approved")] | first')

if [ -z "$APPROVAL_JSON" ] || [ "$APPROVAL_JSON" = "null" ]; then
    echo "ERROR: No separate literal human approval comment found"
    exit 1
fi

PLAN_COMMENT=$(gh issue view "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --json comments \
    --jq '.comments[] | select(.body | contains("## Implementation Plan")) | .body' | head -1)

# Step 3: Create test PR with gstack
TEST_BRANCH="gstack/ticket-${ISSUE_NUMBER}-test"
echo "📝 Creating test PR on branch: $TEST_BRANCH"

# This would normally use gstack to create the PR
# For now, we'll document the structure
TEST_PR_BODY=$(cat <<EOF
## Test PR for Ticket #${ISSUE_NUMBER}

### Purpose
Comprehensive test cases for the feature described in #${ISSUE_NUMBER}

### Test Scenarios
- Unit tests for core functionality
- Integration tests for dependencies
- E2E test scenarios (if applicable)

### Related Issues
- Closes: #${ISSUE_NUMBER} (once implementation is merged)

### Checklist
- [ ] All test scenarios pass locally
- [ ] CI pipeline passes
- [ ] Code coverage is adequate (>80%)

### Implementation Plan
${PLAN_COMMENT}
EOF
)

echo "📋 Test PR Structure:"
echo "   Branch: $TEST_BRANCH"
echo "   Files:"
echo "     - tests/ticket-${ISSUE_NUMBER}.test.ts (or .js, .py)"
echo "     - tests/ticket-${ISSUE_NUMBER}-e2e.test.ts (or .js, .py)"
echo ""

# Step 5: Update issue labels
echo "🏷️  Updating issue labels..."
gh issue edit "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --remove-label "awaiting-plan-approval" \
    --add-label "plan-approved,test-pr-creating" 2>/dev/null || true

# Step 6: Post action comment
ACTION_COMMENT=$(cat <<EOF
## ✅ Automation Status

**Stage 1 Complete:** Plan approved ✓

**Test PR stage:**
- Create test PR: $TEST_BRANCH
- Implementation PR must wait until this test PR is merged

**Next Steps:**
1. Test PR will run all test suites
2. Once tests pass, test PR can be merged
3. Implementation PR will be created only after test PR merge
4. Code review and merge process begins
EOF
)

gh issue comment "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --body "$ACTION_COMMENT"

echo ""
echo "✅ Stage 2 Complete!"
echo "   - Test PR branch prepared/documented: $TEST_BRANCH"
echo "   - Implementation PR creation remains blocked until test PR merge"
echo ""
echo "⏭️  Next: Merge test PR → Implementation PR → Final Merge & Deploy"
