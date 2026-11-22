# 🚀 Claude Ticket Manager Skill - Quick Start

Your Ticket Manager Automation skill is now **loaded and ready to use** in Claude!

---

## ⚡ 5-Minute Quick Start

### 1️⃣ Configure Your Repository

Set the default repository (replace with your repo):

```
I want to work with repository vidit-bhatia/samridhi for ticket management.
Use query filter: is:open label:ready-to-plan
```

### 2️⃣ Pick Your First Ticket

```
Pick the next ticket from samridhi repo
```

The skill will:
- ✅ Query for tickets with `ready-to-plan` label
- ✅ Pick the first one
- ✅ Show you the ticket number and title
- ✅ Label it as `picked-for-planning`

### 3️⃣ Generate a Plan

```
Generate a plan for issue #42
```

The skill will:
- ✅ Create a comprehensive implementation plan
- ✅ Post it as a comment on the issue
- ✅ Change label to `awaiting-plan-approval`

### 4️⃣ Get Plan Approved

You comment on the issue:
```
approved
```

### 5️⃣ Create the PRs

```
Create test and implementation PRs for issue #42
```

The skill will:
- ✅ Create test PR on branch `gstack/ticket-42-test`
- ✅ Create impl PR on branch `gstack/ticket-42-impl`
- ✅ Update issue labels

### 6️⃣ Deploy When Ready

```
Merge and deploy PR #45 to dev environment
```

The skill will:
- ✅ Merge the PR
- ✅ Run E2E tests
- ✅ Generate deployment report
- ✅ Update issue as deployed

---

## 📋 Available Commands

All commands start with the tool name. Use natural language or these patterns:

### Pick Next Ticket
```
"Pick the next ticket from [repo]"
"Get the first ticket ready for planning"
"What's the next ticket to work on?"
```
**Behind the scenes**: Queries `is:open label:ready-to-plan`

### Generate Plan
```
"Generate a plan for issue #42"
"Create implementation plan for #42"
"What's the plan for ticket #42?"
```
**Behind the scenes**: Creates detailed plan with testing strategy and deployment checklist

### Create Test PR
```
"Create test PR for issue #42"
"Add test cases for #42"
"Create tests for ticket #42"
```
**Behind the scenes**: Creates branch `gstack/ticket-42-test` with test file

### Create Implementation PR
```
"Create implementation PR for issue #42"
"Implement ticket #42"
"Start coding for #42"
```
**Behind the scenes**: Creates branch `gstack/ticket-42-impl` with implementation starter

### Merge and Deploy
```
"Merge PR #45 and run tests"
"Deploy PR #45 to dev"
"Merge PR #45 and check E2E tests"
```
**Behind the scenes**: Merges PR, runs E2E tests, generates report

### Check Status
```
"Show status of all tickets"
"Get status for issue #42"
"How many tickets are deployed?"
"What's the status of tickets in samridhi?"
```
**Behind the scenes**: Shows tickets grouped by workflow stage

---

## 🏗️ The 3-Stage Workflow

```
Stage 1: Planning
  ↓ You: "Pick and generate plan"
  ↓ Skill: Picks ticket, posts plan, adds label
  ↓ You: Comment "approved"
  
Stage 2: PR Creation
  ↓ You: "Create PRs"
  ↓ Skill: Creates test PR + impl PR on gstack branches
  ↓ You: Review, implement, push code
  
Stage 3: Deployment
  ↓ You: "Merge and deploy"
  ↓ Skill: Merges PR, runs E2E, generates report
  ↓ Result: Ticket marked as deployed ✅
```

---

## 🎯 Real-World Example

**Day 1 Morning:**
```
You: "Pick the next ticket from samridhi"
Skill: Picked ticket #123: "Add user authentication"

You: "Generate a plan for issue #123"
Skill: Plan posted, awaiting approval
```

**Day 1 Afternoon:**
```
(You review the plan in GitHub)
You: (comment "approved" on issue)

You: "Create PRs for issue #123"
Skill: Created gstack/ticket-123-test and gstack/ticket-123-impl
```

**Day 2-3:**
```
(You implement features and push code)
(You review test cases and merge test PR)
(Maintainers review and approve impl PR)
```

**Day 4:**
```
You: "Merge and deploy PR #124 to dev"
Skill: PR merged ✅
       E2E tests passed ✅
       Report generated ✅
       Issue marked as deployed ✅
```

---

## 🔧 Configuration via Environment

You can set defaults for your environment:

```bash
export TICKET_MANAGER_REPO="vidit-bhatia/samridhi"
export TICKET_MANAGER_QUERY="is:open label:ready-to-plan"
export TICKET_MANAGER_E2E_CMD="npm run test:e2e"
export TICKET_MANAGER_E2E_ENV="dev"
```

Then the skill automatically uses these defaults.

---

## 🏷️ GitHub Labels Used

The skill automatically manages these labels:

| Label | Meaning |
|-------|---------|
| `ready-to-plan` | Ticket picked, waiting for plan generation |
| `awaiting-plan-approval` | Plan posted, waiting for "approved" comment |
| `plan-approved` | Plan was approved, ready for PRs |
| `test-pr-created` | Test PR exists and is ready |
| `impl-pr-created` | Implementation PR exists and is ready |
| `deployed` | Successfully deployed to environment |

---

## 🌳 Git Branch Naming (gstack)

The skill creates branches following gstack conventions:

```
gstack/ticket-42-test    → Test PR for ticket #42
gstack/ticket-42-impl    → Implementation PR for ticket #42
```

These branch names enable **PR stacking** so related PRs are grouped.

---

## ✅ Verification

To verify the skill is working:

1. **List loaded tools**:
   ```
   extensions_manage --operation list
   ```
   Should show: `ticket-manager-automation` ✅

2. **Try a simple status check**:
   ```
   Get status for repo vidit-bhatia/samridhi
   ```

3. **Check logs if something fails**:
   ```
   extensions_manage --operation inspect --name ticket-manager-automation
   ```

---

## 🔗 Integration Points

The skill integrates with:

- **GitHub CLI** (`gh`) - For all GitHub operations
- **gstack** - For PR stack management
- **Git** - For branch operations
- **Your test suite** - E2E test execution

Make sure these are installed and authenticated:
```bash
# Check GitHub CLI
gh auth status

# Check gstack (if using it)
gstack --version

# Check git
git --version
```

---

## 🚨 Common Issues

### "Repository not configured"
**Solution**: Specify repo in your command:
```
"Check status for repo vidit-bhatia/samridhi"
```

### "No tickets ready for planning"
**Solution**: Make sure tickets have the `ready-to-plan` label

### "Failed to merge PR"
**Solution**: Check if there are merge conflicts. The skill will show the error.

### "E2E tests failed"
**Solution**: Check test output in the deployment report. Fix issues and re-run.

---

## 📚 Next Steps

1. **Set up your repository**: Label some issues with `ready-to-plan`
2. **Pick your first ticket**: Try the pick-ticket command
3. **Generate a plan**: Let the skill create an implementation plan
4. **Review and approve**: Comment "approved" to proceed
5. **Create PRs**: Let the skill set up test and implementation branches
6. **Implement and test**: Write your code and pass tests
7. **Deploy**: Let the skill merge and run E2E tests

---

## 🎓 Learn More

- **Full Documentation**: See `README.md` in the files
- **Configuration Guide**: See `CONFIGURATION_GUIDE.md`
- **Automation Details**: See `AUTOMATION_PLAN.md`
- **Testing Guide**: See `TESTING_GUIDE.md`

---

## 💡 Tips

- Use natural language - the skill understands common patterns
- Always wait for skill responses before the next step
- Comment "approved" on GitHub to proceed with PR creation
- Run tests locally before marking as ready for deployment
- Review the deployment report after each merge

---

## 🎉 You're Ready!

Your Ticket Manager skill is loaded and active. Try your first command:

```
"Pick the next ticket from vidit-bhatia/samridhi and generate a plan"
```

The skill will handle the rest! 🚀

---

**Questions or issues?** Check the logs or review the full documentation in the files folder.
