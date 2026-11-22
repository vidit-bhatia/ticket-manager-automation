# 🚀 Ticket Manager Automation

**Automates GitHub ticket management through 3 stages: planning → test PRs → implementation → deployment with E2E testing**

Available as:
- ✅ **Claude Skill** (TypeScript extension for Claude)
- ✅ **GitHub Copilot Automation** (3-stage workflow automation)
- ✅ **CLI Tool** (Bash scripts for local execution)

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/vidit-bhatia/ticket-manager-automation)](https://github.com/vidit-bhatia/ticket-manager-automation/stargazers)

---

## 🎯 Overview

**Ticket Manager** is an intelligent automation system that acts as your **junior engineer**. It:

1. **Picks** the next ticket from your backlog daily
2. **Plans** the implementation with comprehensive details
3. **Creates** test and implementation PRs when approved
4. **Deploys** with automatic E2E testing and reporting

Perfect for teams that want to:
- ✅ Reduce manual coordination overhead
- ✅ Ensure consistent quality standards
- ✅ Accelerate feature delivery
- ✅ Automate repetitive tasks
- ✅ Maintain detailed documentation

---

## ⚡ Quick Start (5 minutes)

### Option 1: Use Claude Skill (Easiest)

```bash
# In Claude, tell it:
"Pick the next ticket from vidit-bhatia/samridhi and generate a plan"

# Skill will immediately:
# ✅ Pick ticket from backlog
# ✅ Generate implementation plan
# ✅ Post to GitHub issue
# ✅ Update labels
# ✅ Wait for your "approved" comment
```

### Option 2: GitHub Copilot Automations

Create 3 automations in your GitHub repository settings:

1. **Daily Planning**: Pick tickets and generate plans (runs daily at 9 AM UTC)
2. **Approval Trigger**: Create PRs when plan is approved (triggered by comment)
3. **Deployment**: Merge and run E2E tests (triggered when PR is ready)

See [AUTOMATION_PROMPTS.md](./docs/AUTOMATION_PROMPTS.md) for copy-paste prompts.

### Option 3: Local CLI

```bash
# Pick a ticket
bash scripts/stage1-daily-planning.sh

# Generate plan (after ticket is picked)
gh issue comment #42 --repo owner/repo --body "Planning complete"

# Create PRs (after approval)
bash scripts/stage2-pr-creation.sh

# Deploy (when implementation is ready)
bash scripts/stage3-deploy.sh
```

---

## 🎓 The 3-Stage Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    STAGE 1: PLANNING                            │
│  • Runs: Daily (9 AM UTC) or on-demand                         │
│  • Picks: First ticket labeled "ready-to-plan"                 │
│  • Creates: Comprehensive implementation plan                  │
│  • Posts: Plan as comment on GitHub issue                      │
│  • Waits: For you to comment "approved"                        │
└─────────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                   STAGE 2: PR CREATION                          │
│  • Trigger: When you comment "approved"                        │
│  • Creates: Test PR on gstack/ticket-{#}-test                 │
│  • Creates: Implementation PR on gstack/ticket-{#}-impl        │
│  • Updates: Labels + pushes branches                           │
│  • Waits: For you to implement and pass reviews               │
└─────────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                 STAGE 3: DEPLOYMENT                             │
│  • Trigger: When implementation PR is ready                    │
│  • Merges: PR to main with conflict detection                 │
│  • Runs: E2E test suite (npm run test:e2e)                    │
│  • Reports: Test results + deployment status                 │
│  • Updates: Issue labels + closes issue                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Features

### ✅ Intelligent Planning
- Generates detailed implementation plans
- Includes testing strategy and deployment checklist
- Posts plans as comments for easy review
- Supports plan discussion before approval

### ✅ Automated PR Management
- Creates test PRs with test file scaffolds
- Creates implementation PRs with branch structure
- Uses **gstack** for PR stacking and rebasing
- Tracks all PRs with descriptive labels

### ✅ Smart Deployment
- Detects and reports merge conflicts
- Runs E2E tests automatically
- Generates comprehensive deployment reports
- Updates issue status automatically

### ✅ Flexible Configuration
- Per-repository customization
- Custom issue query filters
- Configurable test commands
- Support for dev/staging/production environments

### ✅ Zero Manual Oversight
- Never auto-approves (requires explicit "approved" comment)
- Provides clear status updates at each stage
- Shows next steps and required actions
- Generates detailed reports for each deployment

---

## 🔧 Installation

### 1. Claude Skill Installation

```bash
# Session-scoped (this session only)
cp -r .github/extensions/ticket-manager-automation ~/.copilot/extensions/

# User-scoped (all projects)
# macOS/Linux:
mkdir -p ~/.copilot/extensions/ticket-manager-automation
cp -r .github/extensions/* ~/.copilot/extensions/ticket-manager-automation/

# Then reload:
extensions_reload
```

### 2. GitHub Copilot Automations

1. Go to: Repository → Settings → Automations
2. Create 3 automations using prompts from [AUTOMATION_PROMPTS.md](./docs/AUTOMATION_PROMPTS.md)
3. Configure labels using [CONFIGURATION_GUIDE.md](./docs/CONFIGURATION_GUIDE.md)

### 3. Local Setup

```bash
# Clone this repository
git clone https://github.com/vidit-bhatia/ticket-manager-automation.git
cd ticket-manager-automation

# Run setup script
bash scripts/setup-automation.sh OWNER REPO

# This will:
# ✅ Create all 9 required labels
# ✅ Generate configuration files
# ✅ Create test issue for validation
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[README.md](./README.md)** | This file - overview and quick start |
| **[CLAUDE_SKILL_QUICK_START.md](./docs/CLAUDE_SKILL_QUICK_START.md)** | 5-minute guide for Claude skill |
| **[AUTOMATION_PLAN.md](./docs/AUTOMATION_PLAN.md)** | Architecture and workflow details |
| **[CONFIGURATION_GUIDE.md](./docs/CONFIGURATION_GUIDE.md)** | Setup instructions and customization |
| **[AUTOMATION_PROMPTS.md](./docs/AUTOMATION_PROMPTS.md)** | Copy-paste prompts for GitHub UI |
| **[TESTING_GUIDE.md](./docs/TESTING_GUIDE.md)** | Validation and testing procedures |

---

## 🏗️ Project Structure

```
ticket-manager-automation/
├── README.md                           # This file
├── docs/
│   ├── AUTOMATION_PLAN.md             # Architecture details
│   ├── CONFIGURATION_GUIDE.md         # Setup instructions
│   ├── AUTOMATION_PROMPTS.md          # GitHub automation prompts
│   ├── TESTING_GUIDE.md               # Validation guide
│   ├── CLAUDE_SKILL_QUICK_START.md    # Claude skill 5-min guide
│   └── CLAUDE_SKILL_DEPLOYMENT.md     # Deployment options
├── .github/
│   └── extensions/
│       └── ticket-manager-automation/
│           └── extension.mjs           # Claude extension code
├── scripts/
│   ├── setup-automation.sh            # Initial setup
│   ├── stage1-daily-planning.sh       # Daily planning stage
│   ├── stage2-pr-creation.sh          # PR creation stage
│   └── stage3-deploy.sh               # Deployment stage
├── manifest.json                       # Skill configuration
├── LICENSE                             # MIT License
└── .gitignore                          # Git ignore rules
```

---

## 🎯 Real-World Example

**Repository**: `vidit-bhatia/samridhi`

### Day 1 - Morning

```
You: "Pick the next ticket from samridhi repo"

Automation:
✅ Picked: Issue #123 - "Add user authentication"
✅ Generated: Implementation plan
✅ Posted: Plan to issue #123
📋 Status: Awaiting approval

You: (review plan in GitHub)
You: (comment "approved" on issue)
```

### Day 1 - Afternoon

```
You: "Create PRs for ticket #123"

Automation:
✅ Created: gstack/ticket-123-test branch
✅ Created: gstack/ticket-123-impl branch
✅ PRs: Ready for implementation
📋 Status: Waiting for implementation
```

### Day 2-3

```
You: (implement features, write code, push to branch)
Colleagues: (review test PR, approve)
```

### Day 4

```
You: "Merge and deploy PR #124"

Automation:
✅ Merged: PR #124 squash merged
✅ Tests: E2E tests passed (45 scenarios)
✅ Report: Generated deployment report
✅ Issue: #123 marked as deployed
📋 Result: Feature live on dev environment
```

---

## ⚙️ Configuration

### Environment Variables

```bash
# Repository to work with
export TICKET_MANAGER_REPO="vidit-bhatia/samridhi"

# Issue query filter (GitHub search syntax)
export TICKET_MANAGER_QUERY="is:open label:ready-to-plan"

# E2E test command
export TICKET_MANAGER_E2E_CMD="npm run test:e2e"

# Target environment
export TICKET_MANAGER_E2E_ENV="dev"
```

### GitHub Labels

The automation manages 9 labels:

```
ready-to-plan                 → Pick for planning
awaiting-plan-approval        → Plan posted, waiting approval
plan-approved                 → Plan approved, ready for PRs
test-pr-created               → Test PR created
impl-pr-created               → Implementation PR created
implementation-in-progress    → Feature being implemented
e2e-testing                   → Running E2E tests
deployed                      → Successfully deployed
e2e-tested                    → E2E tests completed
```

### Customization

Modify behavior by editing:
- `.github/extensions/ticket-manager-automation/extension.mjs` - Claude skill code
- `scripts/stage*.sh` - Bash automation scripts
- `docs/AUTOMATION_PROMPTS.md` - GitHub automation prompts

See [CONFIGURATION_GUIDE.md](./docs/CONFIGURATION_GUIDE.md) for detailed options.

---

## 🚀 Usage Examples

### In Claude

```
"Pick the next ticket from samridhi"
"Generate a plan for issue #42"
"Create PRs for issue #42"
"Merge and deploy PR #124 to dev"
"Show status for samridhi repo"
```

### Via GitHub Automations

Automations run on schedule or trigger:
- **Daily Planning**: 9 AM UTC every day
- **PR Creation**: When you comment "approved"
- **Deployment**: When PR is ready for merge

### Via CLI

```bash
bash scripts/stage1-daily-planning.sh
bash scripts/stage2-pr-creation.sh
bash scripts/stage3-deploy.sh
```

---

## 🏆 Benefits

| Benefit | Impact |
|---------|--------|
| **Faster Ticket Processing** | Pick and plan tickets in seconds |
| **Consistent Quality** | Same testing strategy for all PRs |
| **Clear Documentation** | Plans posted to every issue |
| **Automated Deployment** | E2E tests run on every merge |
| **Team Alignment** | Everyone sees progress and status |
| **Reduced Manual Work** | No more copy-pasting PR templates |
| **Junior Engineer Behavior** | Requires approval, never auto-deploys |
| **Full Traceability** | Every stage logged in GitHub |

---

## 🔗 Integration

Works with:

- ✅ **GitHub CLI** (`gh`) - Issue and PR management
- ✅ **gstack** - PR stack management and rebasing
- ✅ **Git** - Branch operations
- ✅ **npm/yarn/pnpm** - Test execution
- ✅ **Claude** - AI-powered planning (optional)
- ✅ **GitHub Actions** - CI/CD workflows

---

## 🧪 Testing

Validate your setup:

```bash
# 1. Check prerequisites
gh auth status
gstack --version
git --version

# 2. Run tests
bash scripts/test-automation.sh OWNER REPO

# 3. See TESTING_GUIDE.md for detailed validation
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Repository not configured" | Add `--repo owner/repo` or set env var |
| "No tickets found" | Make sure tickets have `ready-to-plan` label |
| "GitHub CLI error" | Run `gh auth status` to verify auth |
| "gstack not found" | Install: `npm install -g gstack` |
| "E2E tests failing" | Check deployment report for details |
| "Extension not loading" | Run `extensions_reload` and check logs |

See [README.md](./README.md) for more troubleshooting.

---

## 📖 Learn More

- **GitHub Docs**: https://docs.github.com/copilot
- **GitHub CLI**: https://cli.github.com
- **gstack**: https://github.com/uptech/gstack
- **GitHub Actions**: https://github.com/features/actions

---

## 📄 License

MIT © 2024 Vidit Bhatia

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 🎉 Get Started Now

### Option 1: Claude Skill (Recommended for first-time)

1. Install skill: Copy `.github/extensions/` to `~/.copilot/extensions/`
2. Reload: Run `extensions_reload`
3. Try: "Pick the next ticket from vidit-bhatia/samridhi"

### Option 2: GitHub Automations (Best for teams)

1. Configure: Follow [CONFIGURATION_GUIDE.md](./docs/CONFIGURATION_GUIDE.md)
2. Create: 3 automations in GitHub Settings → Automations
3. Use: Label tickets with `ready-to-plan`

### Option 3: Local CLI (Good for testing)

1. Clone: `git clone https://github.com/vidit-bhatia/ticket-manager-automation.git`
2. Setup: `bash scripts/setup-automation.sh OWNER REPO`
3. Run: Execute stage scripts as needed

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/vidit-bhatia/ticket-manager-automation/issues)
- **Docs**: See [docs/](./docs/) folder
- **Quick Help**: [CLAUDE_SKILL_QUICK_START.md](./docs/CLAUDE_SKILL_QUICK_START.md)

---

## 🚀 Summary

**Ticket Manager Automation** is a production-ready system that:

✅ Automates GitHub ticket management  
✅ Available as Claude skill  
✅ Available as GitHub Copilot automations  
✅ Works with existing workflows  
✅ Fully customizable  
✅ Zero production overhead  

**Start automating your workflow today!** 🎉

---

**Made with ❤️ for GitHub Copilot & Claude users**
