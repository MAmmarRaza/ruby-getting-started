# Files Configuration Guide - Bad Code Detection CI Setup

This guide categorizes all files needed for the CI/CD bad code detection system, showing which are **reusable** (can be copied to any Ruby/Rails project) and which need **customization**.

---

## 📋 File Categories

### ✅ **Reusable Files** (Copy to Any Ruby/Rails Project)
These files work out-of-the-box with minimal or no changes.

### ⚙️ **Configurable Files** (Need Project-Specific Customization)
These files need adjustments for your project.

### 📚 **Documentation Files** (Optional but Recommended)
These help your team understand the system.

---

## ✅ REUSABLE FILES (Copy As-Is)

### 1. CI/CD Pipeline

**File:** `.github/workflows/ci.yml`

**Status:** ✅ Mostly reusable, minor customization needed

**What to customize:**
- Ruby version (line 20, 38, 82, 125, 146): Change `'3.3'` to your Ruby version
- Database name (line 62, 106): Change `ruby_getting_started_test` to your app name
- Branch names (line 5, 7): Change `main, develop` to your branch names

**What's already generic:**
- All job configurations
- PostgreSQL service setup
- Environment variables
- Step logic

**Copy to:** Any Ruby/Rails project with GitHub Actions

---

### 2. RuboCop Configuration

**File:** `.rubocop.yml`

**Status:** ✅ Fully reusable

**What to customize:**
- Ruby version (line 6): Change `3.3` to your Ruby version
- Exclusions (lines 8-17): Adjust based on your project structure

**What's already generic:**
- Performance rules
- Rails rules
- Style rules
- All cop configurations

**Copy to:** Any Ruby/Rails project

---

### 3. Bullet Configuration

**File:** `config/initializers/bullet.rb`

**Status:** ✅ Fully reusable

**What to customize:**
- Nothing! Works for any Rails project

**What it does:**
- Enables Bullet gem
- Configures N+1 detection
- Sets up alerts and exceptions

**Copy to:** Any Rails project

---

### 4. Test Environment Bullet Setup

**File:** `config/environments/test.rb` (Bullet section)

**Status:** ✅ Fully reusable

**What to customize:**
- Nothing! Just add the Bullet configuration block

**Code to add:**
```ruby
config.after_initialize do
  if defined?(Bullet)
    Bullet.enable = true
    Bullet.raise = true  # Fail tests if N+1 queries detected
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
end
```

**Copy to:** Any Rails project's `config/environments/test.rb`

---

### 5. Development Environment Bullet Setup

**File:** `config/environments/development.rb` (Bullet section)

**Status:** ✅ Fully reusable

**What to customize:**
- Nothing! Just add the Bullet configuration block

**Code to add:**
```ruby
config.after_initialize do
  if defined?(Bullet)
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end
```

**Copy to:** Any Rails project's `config/environments/development.rb`

---

### 6. Quality Rake Tasks

**File:** `lib/tasks/quality.rake`

**Status:** ✅ Fully reusable

**What to customize:**
- Nothing! Works for any Rails project

**What it does:**
- Provides `rake quality:all` command
- ~~Provides `rake quality:check_queries` command~~ (REMOVED - custom checker was optional)
- Runs RuboCop, Brakeman, tests
- Checks for query patterns

**Copy to:** Any Rails project's `lib/tasks/` directory

---

### 7. Pre-commit Configuration

**File:** `.pre-commit-config.yaml`

**Status:** ✅ Fully reusable

**What to customize:**
- Nothing! Works for any Ruby/Rails project

**What it does:**
- Runs RuboCop before commit
- Runs Brakeman before commit
- Checks for credentials
- Removes trailing whitespace

**Copy to:** Any Ruby/Rails project (requires `pre-commit` gem)

---

### 8. PR Template

**File:** `.github/PULL_REQUEST_TEMPLATE.md`

**Status:** ✅ Mostly reusable

**What to customize:**
- Project-specific checklists (if needed)
- Team-specific requirements

**What's already generic:**
- Query optimization checklist
- Security checklist
- Testing checklist
- Code quality checklist

**Copy to:** Any project using GitHub

---

## ⚙️ CONFIGURABLE FILES (Need Customization)

### 1. Gemfile

**File:** `Gemfile`

**Status:** ⚙️ Add gems to your existing Gemfile

**What to add:**
```ruby
group :development, :test do
  # Code style checker
  gem 'rubocop', '~> 1.66', require: false
  gem 'rubocop-rails', '~> 2.24', require: false
  gem 'rubocop-performance', '~> 1.20', require: false
  
  # Security vulnerability scanner
  gem 'brakeman', '~> 6.0', require: false
  
  # N+1 query detection
  gem 'bullet', '~> 7.0', require: false
  
  # Code coverage
  gem 'simplecov', '~> 0.22', require: false
  
  # Query analysis
  gem 'query_diet', require: false
end
```

**Action:** Add these gems to your existing Gemfile

---

### 2. CI Workflow (Minor Customization)

**File:** `.github/workflows/ci.yml`

**What to customize:**

1. **Ruby version** (appears in 5 places):
   ```yaml
   ruby-version: '3.3'  # Change to your Ruby version
   ```

2. **Database name** (2 places):
   ```yaml
   POSTGRES_DB: ruby_getting_started_test  # Change to your_app_name_test
   DATABASE_URL: postgres://postgres:postgres@localhost:5432/ruby_getting_started_test
   ```

3. **Branch names** (2 places):
   ```yaml
   branches: [ main, develop ]  # Change to your branch names
   ```

4. **Test command** (if not using Rails default):
   ```yaml
   bundle exec rails test  # Change if using RSpec: bundle exec rspec
   ```

---

### 3. RuboCop Config (Minor Customization)

**File:** `.rubocop.yml`

**What to customize:**

1. **Ruby version:**
   ```yaml
   TargetRubyVersion: 3.3  # Change to your Ruby version
   ```

2. **Exclusions** (if your project structure differs):
   ```yaml
   Exclude:
     - 'db/**/*'
     - 'bin/**/*'
     # Add your project-specific exclusions
   ```

---

## 📚 DOCUMENTATION FILES (Optional)

These files help your team but aren't required for the CI to work:

- `DEVELOPER_GUIDELINES.md` - Team guidelines
- `QUERY_REVIEW_CHECKLIST.md` - Code review checklist
- `SETUP_INSTRUCTIONS.md` - Setup guide
- `CI_PIPELINE_EXPLAINED.md` - Pipeline explanation
- `WHY_SEPARATE_QUERY_CHECKS.md` - Technical explanation
- `CODE_QUALITY_SUMMARY.md` - Summary document

**Status:** Optional but recommended

**Action:** Copy and customize for your team

---

## 🚀 Quick Setup Checklist

### Step 1: Copy Reusable Files

```bash
# Create directories
mkdir -p .github/workflows
mkdir -p lib/tasks
mkdir -p config/initializers

# Copy files
cp .github/workflows/ci.yml /path/to/new/project/.github/workflows/
cp .rubocop.yml /path/to/new/project/
cp config/initializers/bullet.rb /path/to/new/project/config/initializers/
cp lib/tasks/quality.rake /path/to/new/project/lib/tasks/
cp .pre-commit-config.yaml /path/to/new/project/
```

### Step 2: Customize CI Workflow

Edit `.github/workflows/ci.yml`:
- [ ] Change Ruby version (5 places)
- [ ] Change database name (2 places)
- [ ] Change branch names (2 places)
- [ ] Change test command if using RSpec

### Step 3: Customize RuboCop

Edit `.rubocop.yml`:
- [ ] Change Ruby version
- [ ] Adjust exclusions if needed

### Step 4: Add Gems

Edit `Gemfile`:
- [ ] Add all gems from the "Gemfile" section above
- [ ] Run `bundle install`

### Step 5: Configure Environments

Edit `config/environments/test.rb`:
- [ ] Add Bullet configuration block

Edit `config/environments/development.rb`:
- [ ] Add Bullet configuration block

### Step 6: Test Locally

```bash
# Test RuboCop
bundle exec rubocop

# Test Brakeman
bundle exec brakeman

# Test query checker
# Note: Custom query checker removed - use Bullet instead (runs automatically in tests)
# BULLET_ENABLED=true bundle exec rails test

# Test with Bullet
BULLET_ENABLED=true bundle exec rails test
```

### Step 7: Push to GitHub

```bash
git add .
git commit -m "Add CI/CD bad code detection"
git push
```

---

## 📊 File Summary Table

| File | Type | Reusable? | Customization Needed |
|------|------|-----------|---------------------|
| `.github/workflows/ci.yml` | CI/CD | ✅ Mostly | Ruby version, DB name, branches |
| `.rubocop.yml` | Config | ✅ Yes | Ruby version, exclusions |
| `config/initializers/bullet.rb` | Config | ✅ Yes | None |
| `config/environments/test.rb` | Config | ✅ Yes | Add Bullet block |
| `config/environments/development.rb` | Config | ✅ Yes | Add Bullet block |
| `lib/tasks/quality.rake` | Code | ✅ Yes | None |
| `.pre-commit-config.yaml` | Config | ✅ Yes | None |
| `.github/PULL_REQUEST_TEMPLATE.md` | Template | ✅ Mostly | Team-specific items |
| `Gemfile` | Config | ⚙️ Add to existing | Add gems to existing file |
| Documentation files | Docs | 📚 Optional | Customize for team |

---

## 🎯 Minimal Setup (Essential Files Only)

If you want the bare minimum, you only need:

1. ✅ `.github/workflows/ci.yml` (customize Ruby version, DB name)
2. ✅ `.rubocop.yml` (customize Ruby version)
3. ✅ `config/initializers/bullet.rb` (no changes)
4. ✅ `config/environments/test.rb` (add Bullet block)
5. ✅ `lib/tasks/quality.rake` (no changes)
6. ⚙️ `Gemfile` (add gems)

**Total:** 6 files (5 reusable + 1 to modify)

---

## 💡 Pro Tips

1. **Start with reusable files** - Copy them first, then customize
2. **Test locally** - Run checks locally before pushing to CI
3. **Gradual adoption** - Enable checks one at a time if needed
4. **Documentation** - Copy docs and customize for your team
5. **Version pinning** - Pin gem versions for consistency

---

## 🔄 Updating for New Projects

**Template approach:**
1. Create a template repository with all reusable files
2. Copy template to new projects
3. Customize only the configurable parts
4. Done!

**Time saved:** ~30 minutes per project setup

---

## ✅ Verification Checklist

After setup, verify:

- [ ] CI runs on push/PR
- [ ] RuboCop checks pass
- [ ] Brakeman scans run
- [ ] Tests run with Bullet
- [ ] Query checker runs
- [ ] Build check passes
- [ ] All jobs complete successfully

---

**Summary:** Most files are reusable! Only need to customize Ruby version, database name, and branch names. Everything else works out-of-the-box! 🚀
