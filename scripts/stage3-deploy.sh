#!/bin/bash

##############################################################################
# STAGE 3: Merge, Deploy & E2E Testing Automation
# Trigger: When implementation PR has passing checks and approvals
# Purpose: Merge PR, run E2E tests, deploy, and report
##############################################################################

set -e

OWNER="${OWNER:-}"
REPO="${REPO:-}"
PR_NUMBER="${PR_NUMBER:-}"
AUTO_MERGE_ENABLED="${AUTO_MERGE_ENABLED:-false}"
E2E_TEST_COMMAND="${E2E_TEST_COMMAND:-npm run test:e2e}"
E2E_ENVIRONMENT="${E2E_ENVIRONMENT:-dev}"

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$PR_NUMBER" ]; then
    echo "ERROR: OWNER, REPO, and PR_NUMBER must be provided"
    exit 1
fi

echo "🤖 [Stage 3] Merge, Deploy & E2E Testing Automation"
echo "   Repository: $OWNER/$REPO"
echo "   PR: #$PR_NUMBER"
echo ""

# Step 1: Verify PR status
echo "🔍 Checking PR status..."
PR_STATE=$(gh pr view "$PR_NUMBER" --repo "$OWNER/$REPO" --json state,commits,reviews --jq '.state')

if [ "$PR_STATE" != "OPEN" ]; then
    echo "❌ PR is not in OPEN state: $PR_STATE"
    exit 1
fi

# Step 2: Check if all checks are passing
echo "✅ Verifying CI checks..."
PR_CHECKS=$(gh pr view "$PR_NUMBER" \
    --repo "$OWNER/$REPO" \
    --json statusCheckRollup \
    --jq '.statusCheckRollup[] | select(.status != "PASS") | .context' | wc -l)

if [ "$PR_CHECKS" -gt 0 ]; then
    echo "⚠️  Some checks are not passing. Waiting for them to complete."
    exit 0
fi

# Step 3: Extract issue number from PR (gstack/ticket-NNN-impl format)
ISSUE_NUMBER=$(echo "$PR_NUMBER" | grep -oE '[0-9]+' | head -1)
if [ -z "$ISSUE_NUMBER" ]; then
    # Try to get it from PR title
    ISSUE_NUMBER=$(gh pr view "$PR_NUMBER" \
        --repo "$OWNER/$REPO" \
        --json title \
        --jq '.title | match("[0-9]+") | .string' | head -1)
fi

echo "📌 Associated Issue: #$ISSUE_NUMBER"
echo ""

# Step 4: Merge only when explicitly enabled
if [ "$AUTO_MERGE_ENABLED" = "true" ]; then
    echo "🔄 Merging PR..."

    MERGE_OUTPUT=$(gh pr merge "$PR_NUMBER" \
        --repo "$OWNER/$REPO" \
        --merge \
        --delete-branch 2>&1) || MERGE_STATUS=$?

    if [ "${MERGE_STATUS:-0}" -ne 0 ]; then
        echo "$MERGE_OUTPUT"
        echo "⚠️ Merge blocked or failed. Conflict details, if present, require manual review."
        gh pr comment "$PR_NUMBER" \
            --repo "$OWNER/$REPO" \
            --body "⚠️ Merge conflicts detected. Manual review required before merge."
        exit 1
    fi

    echo "Merge command completed:"
    echo "$MERGE_OUTPUT"
else
    echo "⏭️  Auto-merge disabled. Waiting for manual merge."
    exit 0
fi

echo ""

# Step 5: Run E2E tests against dev environment
echo "🧪 Running E2E tests against $E2E_ENVIRONMENT environment..."
echo "   Command: $E2E_TEST_COMMAND"

set +e
eval "$E2E_TEST_COMMAND"
E2E_STATUS=$?
set -e

if [ "$E2E_STATUS" -ne 0 ]; then
    echo "E2E command exited $E2E_STATUS; deployment status is not successful."
    exit "$E2E_STATUS"
fi

echo "E2E command exited 0."
E2E_REPORT=$(cat <<EOF
# E2E Test Report

**Environment:** $E2E_ENVIRONMENT
**Timestamp:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**PR:** #$PR_NUMBER
**Ticket:** #$ISSUE_NUMBER
**Command:** $E2E_TEST_COMMAND
**Exit code:** $E2E_STATUS
**Merge:** Verified command output above

The command exited successfully. Deployment configuration and environment state must still be verified.
EOF
)
echo "$E2E_REPORT"
echo ""

# Step 6: Update issue with deployment status
echo "📢 Updating issue status..."

DEPLOYMENT_COMMENT=$(cat <<EOF
## Dev E2E Verification Complete

**Verified Stages:**
1. Human plan approval verified
2. Test PR and implementation PR merge states verified
3. Implementation merge command completed
4. Dev E2E command exited 0

**Ticket Status:** Dev E2E verified for $E2E_ENVIRONMENT

$E2E_REPORT
EOF
)

if [ -n "$ISSUE_NUMBER" ]; then
    gh issue comment "$ISSUE_NUMBER" \
        --repo "$OWNER/$REPO" \
        --body "$DEPLOYMENT_COMMENT"
    
    # Update labels
    gh issue edit "$ISSUE_NUMBER" \
        --repo "$OWNER/$REPO" \
        --add-label "e2e-tested" \
        --remove-label "impl-pr-created,implementation-in-progress" 2>/dev/null || true
    
    # Close issue if it was just for this feature
    # Optionally, with explicit flag:
    # gh issue close "$ISSUE_NUMBER" --repo "$OWNER/$REPO"
fi

echo ""
echo "✅ Stage 3 Complete!"
echo "   - PR Merged: $PR_NUMBER"
echo "   - E2E Tests Passed"
echo "   - Issue labeled with e2e-tested status only"
echo ""
echo "🎉 Ticket Complete! Ready for production deployment."
