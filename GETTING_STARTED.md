# 🚀 Getting Started with Ticket Manager Automation

Welcome! This guide will help you get started using the Ticket Manager Automation in just 5 minutes.

## 📍 What is This?

Ticket Manager Automation is a system that acts as your **junior engineer**. It:

1. **Picks** tickets from your backlog daily
2. **Plans** implementations with comprehensive details
3. **Creates** test and implementation PRs when approved
4. **Deploys** with automatic E2E testing

Perfect for teams that want to automate repetitive GitHub workflows.

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Install (Choose One Method)

#### Method A: Claude Skill (Easiest - 1 minute)
```bash
# Install the Claude skill
mkdir -p ~/.copilot/extensions/ticket-manager-automation
git clone https://github.com/vidit-bhatia/ticket-manager-automation.git temp
cp -r temp/.github/extensions/ticket-manager-automation/* ~/.copilot/extensions/ticket-manager-automation/
rm -rf temp

# Reload extensions
extensions_reload
```

#### Method B: Local Scripts (Test First - 2 minutes)
```bash
# Clone and setup
git clone https://github.com/vidit-bhatia/ticket-manager-automation.git
cd ticket-manager-automation
bash scripts/setup-automation.sh OWNER/REPO
```

#### Method C: GitHub Automations (Team Use - 3 minutes)
1. Go to: Repository → Settings → Automations
2. Create 3 automations using `docs/AUTOMATION_PROMPTS.md`
3. Configure labels using `docs/CONFIGURATION_GUIDE.md`

### Step 2: Configure Your Repository

```bash
# Set the repository
export TICKET_MANAGER_REPO="vidit-bhatia/samridhi"

# Or run setup script (creates labels automatically)
bash scripts/setup-automation.sh vidit-bhatia/samridhi
```

### Step 3: Try It!

#### With Claude Skill:
```
In Claude, type:
"Pick the next ticket from vidit-bhatia/samridhi"
```

#### With Local Scripts:
```bash
bash scripts/stage1-daily-planning.sh
```

#### With GitHub Automations:
1. Create automation
2. Wait for scheduled time or trigger manually
3. Watch automation run

---

## 🎯 Real Example: Your First Ticket

### Day 1 Morning
```
You: "Pick and plan the next ticket"
↓
Automation:
✅ Picks issue #123: "Add authentication"
✅ Generates plan
✅ Posts to GitHub
📋 Waiting for your approval
```

### Day 1 Afternoon
```
You: Comment "approved" on issue
↓
You: "Create the PRs"
↓
Automation:
✅ Creates test PR
✅ Creates implementation PR
📋 Ready for coding
```

### Day 2-3
```
You: Write code and push
Team: Review and approve
```

### Day 4
```
You: "Merge and deploy"
↓
Automation:
✅ Merges PR
✅ Runs E2E tests
✅ Reports success
✅ Closes ticket
```

---

## 📚 Documentation

| Document | For |
|----------|-----|
| **README.md** | Project overview |
| **CLAUDE_SKILL_QUICK_START.md** | 5-min Claude guide |
| **CONFIGURATION_GUIDE.md** | Detailed setup |
| **AUTOMATION_PLAN.md** | How it works |
| **TESTING_GUIDE.md** | Validation |
| **AUTOMATION_PROMPTS.md** | GitHub automation |

---

## ✅ Verification

Make sure everything works:

```bash
# Check prerequisites
gh auth status
gstack --version
git --version

# Try it
"Pick the next ticket from your-repo"  # In Claude
# OR
bash scripts/stage1-daily-planning.sh   # Local
```

---

## 🆘 Issues?

**Extension not loading?**
```bash
extensions_reload
extensions_manage --operation inspect --name ticket-manager-automation
```

**No tickets found?**
Label a ticket with `ready-to-plan`

**E2E tests failing?**
Check the deployment report for details

See `TESTING_GUIDE.md` for more help.

---

## 🎓 Next Steps

1. ✅ Install (choose method above)
2. ✅ Configure your repository
3. ✅ Try your first ticket
4. ✅ Read full documentation
5. ✅ Set up recurring automation

---

## 📖 Learn More

- **Full README**: See main README.md
- **Architecture**: Read AUTOMATION_PLAN.md
- **GitHub Setup**: See AUTOMATION_PROMPTS.md
- **Troubleshooting**: Check TESTING_GUIDE.md

---

**Happy automating!** 🚀

Questions? Check the docs or open an issue on GitHub.
