#!/bin/bash

##############################################################################
# SETUP SCRIPT: Initialize Ticket Management Automation for a Repository
# 
# Usage: ./setup-automation.sh OWNER REPO [QUERY_FILTER] [TIME_UTC]
# Example: ./setup-automation.sh myorg myrepo "is:open label:ready-to-plan" 09
##############################################################################

set -e

OWNER="${1:?Error: OWNER required. Usage: $0 OWNER REPO [QUERY] [TIME]}"
REPO="${2:?Error: REPO required. Usage: $0 OWNER REPO [QUERY] [TIME]}"
QUERY_FILTER="${3:-is:open label:ready-to-plan}"
HOUR_UTC="${4:-9}"

echo "🚀 Ticket Management Automation Setup"
echo "   Repository: $OWNER/$REPO"
echo "   Daily time: $HOUR_UTC:00 UTC"
echo "   Query filter: $QUERY_FILTER"
echo ""

# Step 1: Verify authentication
echo "🔐 Checking GitHub authentication..."
if ! gh auth status &>/dev/null; then
    echo "❌ Not authenticated. Run: gh auth login"
    exit 1
fi
echo "✅ Authenticated"
echo ""

# Step 2: Create required labels
echo "🏷️  Creating required labels..."
LABELS=(
    "awaiting-plan-approval:Plan posted, waiting for user approval"
    "plan-approved:Plan has been approved by user"
    "test-pr-created:Test PR created"
    "impl-pr-created:Implementation PR created"
    "implementation-in-progress:Implementation is in progress"
    "e2e-testing:E2E tests are running"
    "deployed:Successfully deployed to dev"
    "e2e-tested:E2E tests completed and passed"
    "ready-to-plan:Ready for daily planning automation"
)

for label_def in "${LABELS[@]}"; do
    IFS=':' read -r label_name label_desc <<< "$label_def"
    
    if gh label list --repo "$OWNER/$REPO" --jq '.[] | .name' | grep -q "^${label_name}$"; then
        echo "   ⏭️  $label_name (already exists)"
    else
        echo "   ✅ Creating: $label_name"
        gh label create "$label_name" \
            --repo "$OWNER/$REPO" \
            --description "$label_desc" \
            --color "5E8FB0" 2>/dev/null || echo "   ⚠️  Could not create $label_name"
    fi
done
echo ""

# Step 3: Verify automation is enabled
echo "🤖 Checking if automations are enabled..."
AUTOMATIONS_ENABLED=$(gh api "repos/$OWNER/$REPO" --jq '.topics | contains(["github-copilot-automation"])')

if [ "$AUTOMATIONS_ENABLED" != "true" ]; then
    echo "⚠️  Automations may not be enabled for this repository"
    echo "   Enable in: Settings → Features → GitHub Copilot automations"
fi
echo ""

# Step 4: Create automation configuration files
echo "📋 Creating configuration files..."

CONFIG_DIR="$HOME/.copilot-automation/$OWNER/$REPO"
mkdir -p "$CONFIG_DIR"

# Stage 1 config
cat > "$CONFIG_DIR/stage1-config.sh" <<EOF
#!/bin/bash
# Stage 1 Configuration - Daily Ticket Planning

export OWNER="$OWNER"
export REPO="$REPO"
export QUERY_FILTER="$QUERY_FILTER"
export DRY_RUN="false"

# Schedule: Daily at $HOUR_UTC:00 UTC
export SCHEDULE_HOUR_UTC="$HOUR_UTC"
export SCHEDULE_MINUTE_UTC="0"
EOF
chmod +x "$CONFIG_DIR/stage1-config.sh"
echo "   ✅ Created: $CONFIG_DIR/stage1-config.sh"

# Stage 2 config
cat > "$CONFIG_DIR/stage2-config.sh" <<EOF
#!/bin/bash
# Stage 2 Configuration - PR Creation on Approval

export OWNER="$OWNER"
export REPO="$REPO"
export AUTO_MERGE_TESTS="false"
export DEPLOYMENT_CONFIG_PATH="config/deployment.yaml"

# Triggered when issue receives "approved" comment
EOF
chmod +x "$CONFIG_DIR/stage2-config.sh"
echo "   ✅ Created: $CONFIG_DIR/stage2-config.sh"

# Stage 3 config
cat > "$CONFIG_DIR/stage3-config.sh" <<EOF
#!/bin/bash
# Stage 3 Configuration - Merge & Deploy

export OWNER="$OWNER"
export REPO="$REPO"
export AUTO_MERGE_ENABLED="true"
export E2E_TEST_COMMAND="npm run test:e2e"
export E2E_ENVIRONMENT="dev"

# Triggered when implementation PR is ready to merge
EOF
chmod +x "$CONFIG_DIR/stage3-config.sh"
echo "   ✅ Created: $CONFIG_DIR/stage3-config.sh"

echo ""

# Step 5: Display automation creation instructions
echo "📝 Next: Create Automations in GitHub"
echo ""
echo "Option A: Using GitHub UI (Recommended for first setup)"
echo "  1. Go to: https://github.com/$OWNER/$REPO/settings/automations"
echo "  2. Click 'Create Automation'"
echo "  3. Configure each of the 3 stages (see AUTOMATION_PLAN.md)"
echo ""
echo "Option B: Using GitHub CLI"
echo "  Run these commands:"
echo ""

# Generate CLI command for automation creation
cat > "$CONFIG_DIR/create-automations.sh" <<EOF
#!/bin/bash
# Auto-generate automation creation commands

echo "To create automations via CLI, use:"
echo ""

echo "# AUTOMATION 1: Daily Ticket Planning"
echo "gh api graphql -f query='"'"'mutation {'"'"'"
echo "  createAutomation(input: {"
echo "    name: \"Daily Ticket Planning\""
echo "    description: \"Picks one ticket daily and generates implementation plan\""
echo "    prompt: \"See AUTOMATION_PLAN.md\""
echo "  })"
echo "}'"'"'"
echo ""

echo "Note: CLI method requires GraphQL mutations and is complex."
echo "Use GitHub UI instead for easier setup."
EOF
chmod +x "$CONFIG_DIR/create-automations.sh"

cat "$CONFIG_DIR/create-automations.sh"
echo ""

# Step 6: Create test ticket for validation
echo "🧪 Creating test ticket for validation..."
read -p "Create a test issue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    TEST_ISSUE=$(gh issue create \
        --repo "$OWNER/$REPO" \
        --title "[TEST] Sample Feature for Automation Testing" \
        --body "This is a test issue to validate the automation workflow.

## Test Scenario
This issue will be processed through all 3 automation stages.

## Expected Workflow
1. Stage 1: Plan generated
2. User approves plan
3. Stage 2: Test & Implementation PRs created
4. Tests are run and must pass
5. PRs are merged
6. Stage 3: E2E tests run and deployed

## Notes
- Remove 'ready-to-plan' label to disable automation
- Delete this issue after testing" \
        --label "ready-to-plan" \
        --json number \
        --jq '.number')
    
    echo "✅ Created test issue: #$TEST_ISSUE"
    echo "   Add 'ready-to-plan' label to process it tomorrow"
else
    echo "⏭️  Skipped test issue creation"
fi
echo ""

# Step 7: Summary
echo "✅ Setup Complete!"
echo ""
echo "📊 Summary:"
echo "   Repository: $OWNER/$REPO"
echo "   Configuration saved to: $CONFIG_DIR"
echo "   Labels created: $(echo "${LABELS[@]}" | wc -w)"
echo "   Daily planning time: $HOUR_UTC:00 UTC"
echo ""
echo "📚 Documentation:"
echo "   - Implementation Plan: AUTOMATION_PLAN.md"
echo "   - Configuration Guide: CONFIGURATION_GUIDE.md"
echo "   - Setup Scripts: stage1-daily-planning.sh, stage2-pr-creation.sh, stage3-deploy.sh"
echo ""
echo "🚀 Next Steps:"
echo "   1. Create the 3 automations in GitHub UI (Settings → Automations)"
echo "   2. Add 'ready-to-plan' label to tickets you want to process"
echo "   3. Run manual test: gh api repos/$OWNER/$REPO/automations/$AUTOMATION_ID/runs"
echo "   4. Wait for 09:00 UTC tomorrow for first automated run"
echo ""
echo "📞 Support:"
echo "   - View automations: gh api repos/$OWNER/$REPO/automations"
echo "   - View automation logs: gh api repos/$OWNER/$REPO/automations/{id}/runs"
echo "   - Troubleshooting: See CONFIGURATION_GUIDE.md"
echo ""
