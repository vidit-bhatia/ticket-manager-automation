# Contributing to Ticket Manager Automation

Thank you for your interest in contributing! This document provides guidelines and information for contributing to the project.

## 🎯 Code of Conduct

Be respectful, inclusive, and professional. We're all here to build something great together.

## 🐛 Reporting Bugs

Found a bug? Please open an issue with:

1. **Title**: Clear, concise description
2. **Environment**: OS, Node version, Claude/Copilot version
3. **Steps to Reproduce**: Exact steps to replicate the issue
4. **Expected Behavior**: What should happen
5. **Actual Behavior**: What actually happens
6. **Screenshots**: If applicable
7. **Error Logs**: Any error messages or stack traces

## 🎉 Suggesting Enhancements

Have an idea? Open an issue with:

1. **Title**: Clear description of the enhancement
2. **Use Case**: Why is this needed?
3. **Proposed Solution**: How should it work?
4. **Alternatives Considered**: Other options you thought of
5. **Additional Context**: Screenshots, examples, etc.

## 🚀 Pull Requests

### Before Starting

1. Check [issues](https://github.com/vidit-bhatia/ticket-manager-automation/issues) for existing work
2. Create an issue for your contribution (unless fixing a bug already reported)
3. Fork the repository
4. Create a feature branch: `git checkout -b feature/my-feature`

### While Working

1. **Follow the Code Style**:
   - Use consistent formatting
   - Comment complex logic
   - Use clear variable names

2. **Test Your Changes**:
   - Run existing tests: `bash scripts/test-automation.sh OWNER REPO`
   - Add tests for new functionality
   - Test in multiple scenarios

3. **Write Good Commits**:
   ```bash
   git commit -m "feature: Add new capability X"
   git commit -m "fix: Resolve issue with Y"
   git commit -m "docs: Update README for feature X"
   ```

### Submitting a PR

1. Push to your fork: `git push origin feature/my-feature`
2. Open a PR with:
   - **Title**: Clear description of changes
   - **Description**: What changed and why
   - **Related Issues**: Link any related issues
   - **Testing**: How you tested the changes
   - **Screenshots**: If UI changes

3. Address review feedback promptly

## 📝 Documentation

If your change affects documentation:

1. Update relevant `.md` files in `/docs`
2. Update `README.md` if needed
3. Update comments in code
4. Test that links work

## 🏗️ Project Structure

```
ticket-manager-automation/
├── README.md                           # Main documentation
├── docs/                               # Detailed documentation
│   ├── AUTOMATION_PLAN.md             # Architecture
│   ├── CONFIGURATION_GUIDE.md         # Setup guide
│   ├── AUTOMATION_PROMPTS.md          # GitHub prompts
│   ├── TESTING_GUIDE.md               # Testing guide
│   ├── CLAUDE_SKILL_QUICK_START.md    # Claude skill guide
│   └── CLAUDE_SKILL_DEPLOYMENT.md     # Deployment options
├── .github/
│   └── extensions/
│       └── ticket-manager-automation/
│           └── extension.mjs           # Claude extension code
├── scripts/
│   ├── setup-automation.sh            # Setup script
│   ├── stage1-daily-planning.sh       # Stage 1
│   ├── stage2-pr-creation.sh          # Stage 2
│   └── stage3-deploy.sh               # Stage 3
├── manifest.json                       # Skill configuration
├── LICENSE                             # MIT License
└── .gitignore                          # Git ignore rules
```

## 🔧 Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/ticket-manager-automation.git
cd ticket-manager-automation

# Install dependencies
npm install -g gstack  # For PR stack management
brew install gh        # GitHub CLI (if on macOS)

# Setup your test repository
bash scripts/setup-automation.sh OWNER/REPO

# Test your changes
bash scripts/test-automation.sh OWNER/REPO
```

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
bash scripts/test-automation.sh OWNER/REPO

# Test specific stage
bash scripts/stage1-daily-planning.sh
```

### Manual Testing

1. Create a test repository
2. Label a test issue with `ready-to-plan`
3. Run the automation stages manually
4. Verify GitHub issue updates are correct

### Integration Testing

1. Set up with real repository
2. Test full 3-stage workflow
3. Verify all labels update correctly
4. Check deployment reports are generated

## 📚 Documentation Changes

Changes affecting documentation should include:

1. Updated `.md` files
2. Updated code comments
3. Updated examples
4. Updated diagrams (if applicable)

## 🎁 Branching Strategy

```
main
  ↑
  ├── feature/new-capability
  ├── fix/bug-name
  ├── docs/documentation-update
  └── chore/maintenance-task
```

## 🔄 Review Process

1. **Automated Checks**: Tests must pass
2. **Code Review**: At least one approval needed
3. **Documentation Review**: Docs must be clear and accurate
4. **Final Approval**: Maintainer approval before merge

## 🚀 Release Process

1. Update version in `manifest.json`
2. Update `CHANGELOG.md` (if exists)
3. Create GitHub release with tag
4. Update documentation if needed

## 📋 Checklist Before Submitting PR

- [ ] Code follows project style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] No unnecessary dependencies added
- [ ] Commit messages are clear
- [ ] PR description is complete
- [ ] Related issues linked

## 🤔 Questions?

1. Check existing issues and discussions
2. Read documentation in `/docs`
3. Open a new issue with question label

## 🙏 Thanks!

We appreciate your contributions and effort to make Ticket Manager Automation better!

---

Happy contributing! 🚀
