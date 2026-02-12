# Setup Instructions - Code Quality & CI/CD

This document explains how to set up the code quality tools and CI/CD pipeline to prevent bad code from being deployed.

## 🚀 Quick Setup

### 1. Install Dependencies

```bash
bundle install
```

This will install:
- **RuboCop** - Code style and quality checker
- **Brakeman** - Security vulnerability scanner
- **Bullet** - N+1 query detection
- **SimpleCov** - Code coverage
- **Query Diet** - Query analysis

### 2. Configure GitHub Actions

The CI/CD pipeline is already configured in `.github/workflows/ci.yml`. It will automatically:
- Run on every push to `main` or `develop` branches
- Run on every pull request
- Block deployment if any checks fail

**No additional setup needed** - GitHub Actions will run automatically when you push code.

### 3. Set Up Pre-commit Hooks (Optional but Recommended)

```bash
# Install pre-commit gem
gem install pre-commit

# Install hooks
pre-commit install
```

This will run quality checks before you commit code locally.

### 4. Configure Bullet for Development

Bullet is already configured in:
- `config/initializers/bullet.rb` - Main configuration
- `config/environments/development.rb` - Development settings
- `config/environments/test.rb` - Test settings (will fail tests if N+1 detected)

### 5. Test the Setup

```bash
# Run all quality checks
bundle exec rake quality:all

# Run RuboCop
bundle exec rubocop

# Run Brakeman
bundle exec brakeman

# Run tests with Bullet
BULLET_ENABLED=true bundle exec rails test
```

## 📋 What Gets Checked Automatically

### In CI/CD Pipeline:

1. **Code Style (RuboCop)**
   - Rails conventions
   - Code complexity
   - Performance anti-patterns
   - **Blocks deployment if fails**

2. **Security (Brakeman)**
   - SQL injection risks
   - XSS vulnerabilities
   - Mass assignment issues
   - **Blocks deployment if critical issues found**

3. **Tests with N+1 Detection**
   - All tests must pass
   - Bullet enabled - **fails if N+1 queries detected**
   - Query pattern checks

4. **Query Performance**
   - Pattern matching for common issues
   - Database query analysis

5. **Build Verification**
   - Ensures app can be built
   - Database migrations work

### In Pre-commit Hooks (if installed):

- RuboCop checks
- Brakeman scan
- Query pattern checks
- Credential detection

## 🎯 Developer Workflow

### Before Committing:

```bash
# 1. Run quality checks
bundle exec rake quality:all

# 2. Auto-fix RuboCop issues
bundle exec rubocop -a

# 3. Run tests
bundle exec rails test

# 4. Check for N+1 queries
BULLET_ENABLED=true bundle exec rails test
```

### Before Creating PR:

1. Ensure all local checks pass
2. Push to feature branch
3. Create PR - CI will run automatically
4. Address any CI failures
5. Get code review approval
6. Merge only when CI passes

### Before Deploying to Production:

1. ✅ All CI checks pass
2. ✅ Code review approved
3. ✅ Tested on staging
4. ✅ No Bullet warnings
5. ✅ Query performance acceptable

## 🔧 Configuration Files

- `.rubocop.yml` - RuboCop rules and configuration
- `.github/workflows/ci.yml` - CI/CD pipeline
- `.pre-commit-config.yaml` - Pre-commit hooks
- `config/initializers/bullet.rb` - Bullet configuration
- `lib/tasks/quality.rake` - Quality check rake tasks

## 📚 Documentation

- `DEVELOPER_GUIDELINES.md` - Comprehensive developer guidelines
- `QUERY_REVIEW_CHECKLIST.md` - Query review checklist
- `.github/PULL_REQUEST_TEMPLATE.md` - PR template with checklists

## 🚨 Troubleshooting

### CI Fails but Works Locally:

1. Check Ruby version matches CI
2. Run `bundle install` to ensure dependencies match
3. Check environment variables in CI

### Bullet Not Catching N+1:

1. Ensure Bullet is enabled: `BULLET_ENABLED=true`
2. Check `config/initializers/bullet.rb` is loaded
3. Review Bullet logs in `log/bullet.log`

### RuboCop Fails:

```bash
# See what's wrong
bundle exec rubocop

# Auto-fix what can be fixed
bundle exec rubocop -a

# Fix remaining issues manually
```

### Brakeman Finds Issues:

```bash
# See detailed report
bundle exec brakeman

# Review and fix security issues
# Some warnings may be false positives - document why
```

## 🎓 Training Resources

1. **Read `DEVELOPER_GUIDELINES.md`** - Essential reading for all developers
2. **Review `QUERY_REVIEW_CHECKLIST.md`** - Before code reviews
3. **Check PR template** - Use it for all PRs

## 🔄 Continuous Improvement

- Review CI failures and update rules if needed
- Add new checks as issues are discovered
- Update thresholds based on production metrics
- Share learnings with the team

---

**Remember:** The goal is to catch issues early, not to block developers. If a rule is too strict, discuss with the team and adjust! 🤝

