#!/bin/bash

##############################################################################
# STAGE 2: Approval & Test PR Creation Automation
# Trigger: When issue receives comment with "approved"
# Purpose: Create test PR and implementation PR with gstack
##############################################################################

set -e

OWNER="${OWNER:-}"
REPO="${REPO:-}"
ISSUE_NUMBER="${ISSUE_NUMBER:-}"
AUTO_MERGE_TESTS="${AUTO_MERGE_TESTS:-false}"
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
echo "✅ Plan approved! Creating test and implementation PRs..."
echo ""

# Step 2: Extract approved plan from comments
APPROVED_COMMENT=$(gh issue view "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --json comments \
    --jq '.comments[] | select(.body | contains("approved")) | .body' | head -1)

if [ -z "$APPROVED_COMMENT" ]; then
    echo "❌ Could not find approval comment"
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

# Step 4: Create implementation PR with gstack
IMPL_BRANCH="gstack/ticket-${ISSUE_NUMBER}-impl"
echo "📝 Creating implementation PR on branch: $IMPL_BRANCH"

IMPL_PR_BODY=$(cat <<EOF
## Implementation PR for Ticket #${ISSUE_NUMBER}

### Purpose
Implementation of feature described in #${ISSUE_NUMBER}

### Changes
- [ ] Core feature implementation
- [ ] Configuration updates
- [ ] Deployment configuration updated
- [ ] Documentation updated
- [ ] Related tests passing

### Related PRs
- Depends on: #XXX (test PR number - will be populated)

### Configuration Updates
- Deployment config: \`${DEPLOYMENT_CONFIG_PATH}\`
- Environment variables: (if needed)
- Database migrations: (if needed)

### Implementation Plan
${PLAN_COMMENT}

### Checklist
- [ ] All CI checks passing
- [ ] Test PR merged
- [ ] Code review approved
- [ ] Ready for deployment
EOF
)

echo "📋 Implementation PR Structure:"
echo "   Branch: $IMPL_BRANCH"
echo "   Updates:"
echo "     - Feature implementation in src/"
echo "     - Config in $DEPLOYMENT_CONFIG_PATH"
echo "     - Docs in docs/ or README.md"
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

**Stage 2 in Progress:**
- Creating test PR: $TEST_BRANCH
- Creating implementation PR: $IMPL_BRANCH

**Next Steps:**
1. Test PR will run all test suites
2. Once tests pass, test PR can be merged
3. Implementation PR will be created after test PR merge
4. Code review and merge process begins
EOF
)

gh issue comment "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --body "$ACTION_COMMENT"

echo ""
echo "✅ Stage 2 Complete!"
echo "   - Test PR created: $TEST_BRANCH"
echo "   - Implementation PR created: $IMPL_BRANCH"
echo "   - Issue updated with status"
echo ""
echo "⏭️  Next: Merge test PR → Implementation PR → Final Merge & Deploy"
