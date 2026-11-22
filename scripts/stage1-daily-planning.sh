#!/bin/bash

##############################################################################
# STAGE 1: Daily Ticket Planning Automation
# Trigger: Daily at 09:00 UTC
# Purpose: Pick one ticket, generate plan, post as comment, wait for approval
##############################################################################

set -e

# Configuration (passed from automation parameters)
OWNER="${OWNER:-}"
REPO="${REPO:-}"
QUERY_FILTER="${QUERY_FILTER:-is:open label:ready-to-plan}"
DRY_RUN="${DRY_RUN:-false}"

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "ERROR: OWNER and REPO must be provided"
    exit 1
fi

echo "🤖 [Stage 1] Daily Ticket Planning Automation"
echo "   Repository: $OWNER/$REPO"
echo "   Query Filter: $QUERY_FILTER"
echo ""

# Step 1: Query GitHub for first unscheduled ticket
echo "📋 Querying for tickets matching filter..."
TICKET=$(gh issue list \
    --repo "$OWNER/$REPO" \
    --search "$QUERY_FILTER" \
    --json number,title,body \
    --limit 1 \
    --jq '.[] | "\(.number)|\(.title)|\(.body)"' || echo "")

if [ -z "$TICKET" ]; then
    echo "❌ No tickets found matching filter"
    exit 0
fi

ISSUE_NUMBER=$(echo "$TICKET" | cut -d'|' -f1)
ISSUE_TITLE=$(echo "$TICKET" | cut -d'|' -f2)
ISSUE_BODY=$(echo "$TICKET" | cut -d'|' -f3)

echo "✅ Found ticket: #$ISSUE_NUMBER - $ISSUE_TITLE"
echo ""

# Step 2: Check if already has plan comment (avoid duplicates)
EXISTING_PLAN=$(gh issue view "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --json comments \
    --jq '.comments[] | select(.body | contains("## Implementation Plan")) | .id' | head -1)

if [ -n "$EXISTING_PLAN" ]; then
    echo "⚠️  Plan already exists for this ticket. Skipping."
    exit 0
fi

# Step 3: Generate implementation plan using Claude
# In production, this would call the Claude API
# For now, we'll create a template
PLAN=$(cat <<'EOF'
## Implementation Plan

### Objective
Address the requirements stated in this ticket.

### Approach
1. **Analysis Phase**
   - Understand requirements and acceptance criteria
   - Identify dependencies and blockers
   
2. **Design Phase**
   - Design solution architecture
   - Plan code changes and structure
   
3. **Implementation Phase**
   - Write implementation code
   - Add comprehensive tests
   - Update documentation
   
4. **Review Phase**
   - Code review with maintainers
   - Address feedback
   - Merge when approved

### Technical Details
- Files to modify: (Will be determined during implementation)
- Dependencies: (Will be identified during analysis)
- Testing strategy: Unit + Integration + E2E scenarios

### Estimated Timeline
- Planning & Design: 1-2 hours
- Implementation: 4-8 hours  
- Testing & Review: 2-4 hours

---

**Status**: Awaiting approval

To approve, reply with a comment containing: `approved`

You can also discuss improvements to this plan before approving.
EOF
)

if [ "$DRY_RUN" = "true" ]; then
    echo "🔍 DRY RUN MODE - Would post this plan:"
    echo "$PLAN"
    exit 0
fi

# Step 4: Post plan as comment
echo "📝 Posting implementation plan..."
gh issue comment "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --body "$PLAN"

# Step 5: Add awaiting-plan-approval label
echo "🏷️  Adding awaiting-plan-approval label..."
gh issue edit "$ISSUE_NUMBER" \
    --repo "$OWNER/$REPO" \
    --add-label "awaiting-plan-approval" \
    --remove-label "ready-to-plan" 2>/dev/null || true

echo ""
echo "✅ Stage 1 Complete!"
echo "   - Plan posted as comment"
echo "   - Waiting for user approval (comment: 'approved')"
