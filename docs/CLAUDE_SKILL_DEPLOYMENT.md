# 🚀 Claude Skill Deployment Guide

## Ticket Manager Automation Skill for Claude

This is a complete Claude skill (extension) that adds ticket management automation to Claude.

---

## 📦 What's Included

### Files
- `claude-skill-ticket-manager.ts` - Main skill implementation with 6 tools
- `manifest.json` - Skill configuration and metadata
- This deployment guide

### Tools Provided
1. **ticket_pick_next** - Pick next ticket from backlog
2. **ticket_generate_plan** - Generate implementation plan
3. **ticket_create_test_pr** - Create test PR
4. **ticket_create_impl_pr** - Create implementation PR
5. **ticket_merge_deploy** - Merge and deploy with E2E tests
6. **ticket_get_status** - Get automation status

---

## ⚡ Quick Deploy

### Option 1: Session-Scoped (This Session Only)

```bash
# Install in current session
# 1. Create a .github/extensions/ folder in your repository
# 2. Copy both files there:
#    - claude-skill-ticket-manager.ts
#    - manifest.json

# Then reload extensions
extensions_reload
```

### Option 2: User-Scoped (All Projects)

```bash
# Install for your user across all projects
# macOS: ~/.copilot/extensions/
# Linux: ~/.copilot/extensions/
# Windows: %APPDATA%\.copilot\extensions\

# 1. Create folder: ~/.copilot/extensions/ticket-manager-skill/
# 2. Copy files:
cp claude-skill-ticket-manager.ts ~/.copilot/extensions/ticket-manager-skill/
cp manifest.json ~/.copilot/extensions/ticket-manager-skill/

# Reload extensions
extensions_reload
```

### Option 3: Project-Scoped (This Repository)

```bash
# Install in current repository
mkdir -p .github/extensions/ticket-manager-skill
cp claude-skill-ticket-manager.ts .github/extensions/ticket-manager-skill/
cp manifest.json .github/extensions/ticket-manager-skill/

# Commit to repository
git add .github/extensions/
git commit -m "Add ticket manager automation skill"
git push

# Reload extensions
extensions_reload
```

---

## 🎯 Usage Examples

### Basic Commands

```
# Pick next ticket
@ticket-manager pick_ticket --repo vidit-bhatia/samridhi

# Generate a plan
@ticket-manager generate_plan --issue 42 --repo vidit-bhatia/samridhi

# Create PRs
@ticket-manager create_prs --issue 42 --repo vidit-bhatia/samridhi

# Deploy
@ticket-manager deploy --pr 45 --repo vidit-bhatia/samridhi

# Check status
@ticket-manager status --repo vidit-bhatia/samridhi --issue 42
```

### In Conversation

```
You: "Pick the next ticket from samridhi repo and generate a plan"

Skill will:
1. Pick ticket using ticket_pick_next tool
2. Generate plan using ticket_generate_plan tool
3. Show you the plan
4. Wait for your confirmation

You: "Looks good, create the PRs"

Skill will:
1. Create test PR using ticket_create_test_pr tool
2. Create impl PR using ticket_create_impl_pr tool
3. Update issue labels
4. Report success
```

---

## 🔧 Configuration

### Set Default Repository

In Claude conversation:
```
"Use repository vidit-bhatia/samridhi as default for all commands"
```

### Custom Query Filter

```
"Use query filter: is:open label:feature priority:high"
```

### E2E Test Environment

```
"Run E2E tests in staging environment with: npm run test:e2e:staging"
```

---

## 📋 Workflow

### Complete Example Workflow

```
Day 1 (Morning):
You: "Pick the next ticket for planning"
Skill: Picks ticket, shows details

You: "Generate a plan"
Skill: Creates comprehensive plan

You: "Post it and wait for approval"
Skill: Posts plan to issue, adds label

---

Day 1 (Afternoon):
(You review plan and comment: "approved")

You: "Create the PRs"
Skill: Creates test PR and impl PR
       Updates labels
       Shows PR links

---

Day 2-3:
(You review test cases, merge test PR)
(Maintainers review impl PR, approve)

You: "Deploy the implementation"
Skill: Merges PR
       Runs E2E tests
       Generates report
       Updates issue

Result: Issue marked as "deployed" ✅
```

---

## 🎓 Integration with Other Tools

### With GitHub CLI

Skill uses `gh` commands internally:
```bash
gh issue list
gh issue comment
gh pr create
gh pr merge
```

### With gstack

For PR stack management:
```bash
gstack push --create-pr
gstack merge
```

### With Test Runners

Custom commands:
```
npm run test:e2e
npm run test:unit
pytest tests/
```

---

## 🔒 Permissions Required

### GitHub Scopes
- `repo` - Full repository access
- `workflow` - GitHub Actions workflows
- `issues` - Create/manage issues

### CLI Tools
- `gh` - GitHub CLI (authenticated)
- `git` - Git for branches/merges
- `gstack` - PR stack management

### Local Permissions
- Read/write to repository
- Execute test commands
- Modify branches

---

## 📊 Monitoring

### Check if Skill is Loaded

```bash
extensions_manage --operation list
```

Should show: `ticket-manager-skill` with status ✅

### View Logs

```bash
extensions_manage --operation inspect --name ticket-manager-skill
```

---

## 🐛 Troubleshooting

### Skill Not Loading

```bash
# 1. Check installation path
ls ~/.copilot/extensions/ticket-manager-skill/

# 2. Verify file names are correct
# Should be: claude-skill-ticket-manager.ts and manifest.json

# 3. Reload extensions
extensions_reload

# 4. Check logs
extensions_manage --operation inspect --name ticket-manager-skill
```

### Commands Not Recognized

```bash
# Make sure to use correct prefix:
@ticket-manager <command>

# Or if installed globally, just:
ticket_manager <command>
```

### TypeScript Compilation Error

```bash
# Update TypeScript if needed
npm install -g typescript

# Or use pre-compiled version
# (The .ts file will auto-compile in Claude)
```

---

## 🚀 Advanced Features

### Custom Hooks

Add this to extend the skill:

```typescript
// Add to claude-skill-ticket-manager.ts

export const hooks = {
  onTicketPicked: (ticket) => {
    console.log("Picked:", ticket);
  },
  
  onPlanGenerated: (plan) => {
    console.log("Plan ready for approval");
  },
  
  onPRCreated: (pr) => {
    console.log("PR created:", pr.number);
  },
  
  onDeployed: (result) => {
    console.log("Deployed successfully");
  }
};
```

### Extend with Webhooks

Add GitHub webhooks to trigger skill automatically:

```json
{
  "url": "https://your-claude-instance/webhook",
  "events": ["issues.opened", "issue_comment.created", "pull_request.ready_for_review"],
  "active": true
}
```

### Add Slack Integration

```typescript
// Add to skill

const notifySlack = async (message: string) => {
  const webhook = process.env.SLACK_WEBHOOK_URL;
  await fetch(webhook, {
    method: "POST",
    body: JSON.stringify({ text: message })
  });
};
```

---

## 📚 File Structure

```
claude-ticket-manager-skill/
├── claude-skill-ticket-manager.ts    # Main implementation
├── manifest.json                     # Configuration
├── README.md                         # Documentation
└── .github/
    └── workflows/
        └── auto-deploy.yml           # Optional CI/CD workflow
```

---

## 🔄 Update Process

### Update Skill to Latest Version

```bash
# 1. Remove old installation
rm -rf ~/.copilot/extensions/ticket-manager-skill/

# 2. Install new version
cp -r ticket-manager-skill ~/.copilot/extensions/

# 3. Reload extensions
extensions_reload
```

### Breaking Changes

If updating from older version:
- Run `extensions_reload` to clear cache
- Restart Claude app
- Test all commands

---

## 📞 Support

### Documentation
- See: CLAUDE_DEPLOYMENT_GUIDE.md
- See: README.md
- See: AUTOMATION_PLAN.md

### Debugging
```bash
# View extension logs
extensions_manage --operation inspect --name ticket-manager-skill

# Enable debug mode
export DEBUG=ticket-manager:*

# Run test
@ticket-manager status --repo vidit-bhatia/samridhi
```

### Reporting Issues
1. Check logs: `extensions_manage --operation inspect`
2. Try reloading: `extensions_reload`
3. Verify configuration in manifest.json
4. Test GitHub CLI: `gh auth status`

---

## ✅ Verification Checklist

After installing:

- [ ] Skill appears in `extensions_manage --operation list`
- [ ] Can use `@ticket-manager` prefix
- [ ] Can run: `@ticket-manager status --repo owner/repo`
- [ ] GitHub CLI authenticated: `gh auth status`
- [ ] gstack installed: `gstack --version`
- [ ] Test command works: `npm run test:e2e` (or your command)

---

## 🎉 You're All Set!

The Ticket Manager skill is ready to use. Try it now:

```
@ticket-manager pick_ticket --repo vidit-bhatia/samridhi
```

The skill will:
✅ Pick the next ticket
✅ Generate a plan
✅ Create PRs on approval
✅ Deploy and test
✅ Generate reports

**Happy automating!** 🚀
