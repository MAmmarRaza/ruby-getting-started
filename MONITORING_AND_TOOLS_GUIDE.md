# Monitoring & Tools Guide

## 📋 Overview

This document explains what is being monitored in your CI/CD pipeline and what each tool is capable of detecting.

---

## 🎯 Current Monitoring System

Your application uses a **multi-layered defense system** with 4 parallel CI jobs:

1. **Code Style & Linting** (RuboCop)
2. **Security Scanning** (Brakeman)
3. **Tests & Query Analysis** (Rails tests + Bullet)
4. **Build Check** (Asset compilation)

---

## 🔍 Tool-by-Tool Breakdown

### 1. RuboCop - Code Style & Static Analysis

**What it is:** A Ruby static code analyzer and formatter that enforces style guide rules and detects potential issues.

**When it runs:** 
- ✅ In CI (`lint` job)
- ✅ Pre-commit hooks (optional)
- ✅ Manually: `bundle exec rubocop`

**What it detects:**

#### Code Style Issues:
- ✅ Inconsistent indentation and spacing
- ✅ Line length violations
- ✅ Trailing whitespace
- ✅ String quote style (single vs double)
- ✅ Method length and complexity
- ✅ Class/module length

#### Performance Issues:
- ✅ **`Performance/Count`** - Using `count` on loaded collections (should use `size`)
- ✅ **`Performance/MapCompact`** - Using `map` + `compact` (should use `filter_map`)
- ✅ **`Performance/Sum`** - Using `inject` or `reduce` for summing (should use `sum`)
- ✅ **`Performance/UnfreezeString`** - Unnecessary string unfreezing
- ✅ **`Performance/RedundantBlockCall`** - Redundant block calls

#### Rails-Specific Issues:
- ✅ **`Rails/FindEach`** - Using `.each` on ActiveRecord relations (should use `.find_each`)
- ✅ **`Rails/Pluck`** - Using `map` to get attributes (should use `pluck`)
- ✅ **`Rails/FindBy`** - Using `where(...).first` (should use `find_by`)
- ✅ **`Rails/IndexBy`** - Using `each_with_object` for indexing (should use `index_by`)
- ✅ **`Rails/SkipsModelValidations`** - Skipping validations unsafely
- ✅ **`Rails/HasManyOrHasOneDependent`** - Missing `dependent` option on associations
- ✅ **`Rails/InverseOf`** - Missing `inverse_of` on associations

#### What RuboCop CANNOT Detect:
- ❌ Actual N+1 queries (only patterns)
- ❌ Runtime errors
- ❌ Security vulnerabilities (Brakeman handles this)
- ❌ Database query performance (only code patterns)
- ❌ Cross-file issues reliably

**Example violations:**

```ruby
# ❌ RuboCop will flag this:
users = User.all
users.each { |u| puts u.name }
# Rails/FindEach: Use find_each instead of each

# ✅ RuboCop will pass:
User.find_each { |u| puts u.name }

# ❌ RuboCop will flag this:
posts.map { |p| p.user_id }.compact
# Performance/MapCompact: Use filter_map instead

# ✅ RuboCop will pass:
posts.filter_map { |p| p.user_id }
```

**Configuration:** `.rubocop.yml`

---

### 2. Brakeman - Security Vulnerability Scanner

**What it is:** A static analysis security vulnerability scanner for Ruby on Rails applications.

**When it runs:**
- ✅ In CI (`security` job)
- ✅ Pre-commit hooks (optional)
- ✅ Manually: `bundle exec brakeman`

**What it detects:**

#### SQL Injection:
- ✅ Unsafe SQL queries
- ✅ SQL injection in `where` clauses
- ✅ Raw SQL without proper sanitization

#### Cross-Site Scripting (XSS):
- ✅ Unescaped user input in views
- ✅ Missing `html_safe` or `sanitize` calls
- ✅ Unsafe string interpolation in HTML

#### Mass Assignment:
- ✅ Missing `strong_parameters`
- ✅ Unsafe `params` usage
- ✅ Mass assignment vulnerabilities

#### Authentication & Authorization:
- ✅ Missing authentication checks
- ✅ Insecure password storage
- ✅ Missing authorization checks
- ✅ Insecure session management

#### Other Security Issues:
- ✅ **Command Injection** - Unsafe shell commands
- ✅ **File Access** - Insecure file operations
- ✅ **Cryptographic Issues** - Weak encryption/hashing
- ✅ **Information Disclosure** - Exposed sensitive data
- ✅ **Redirect Issues** - Open redirects
- ✅ **CSRF Protection** - Missing CSRF tokens
- ✅ **SSL/TLS Issues** - Insecure connections

**Example vulnerabilities:**

```ruby
# ❌ Brakeman will flag this:
User.where("name = '#{params[:name]}'")
# SQL Injection vulnerability

# ✅ Brakeman will pass:
User.where(name: params[:name])

# ❌ Brakeman will flag this:
<%= params[:content] %>
# XSS vulnerability

# ✅ Brakeman will pass:
<%= sanitize(params[:content]) %>

# ❌ Brakeman will flag this:
User.create(params[:user])
# Mass assignment vulnerability

# ✅ Brakeman will pass:
User.create(user_params)
```

**Output:** Generates `brakeman-report.json` in CI

**Configuration:** Default configuration (can be customized)

---

### 3. Bullet - N+1 Query Detection

**What it is:** A runtime gem that detects N+1 queries, unused eager loading, and counter cache opportunities.

**When it runs:**
- ✅ In CI (`test` job) - **Automatically enabled**
- ✅ In development (optional)
- ✅ In tests: `BULLET_ENABLED=true bundle exec rails test`

**What it detects:**

#### N+1 Queries:
- ✅ **Actual N+1 queries** - When associations are accessed without eager loading
- ✅ **Cross-file N+1** - Detects N+1 across controller → view boundaries
- ✅ **Runtime detection** - Sees actual database queries happening

**Example:**
```ruby
# Controller:
@users = User.all

# View:
<% @users.each do |user| %>
  <%= user.posts.count %>  # N+1 query!
<% end %>

# Bullet detects:
# GET /users
# User Load (1 query)
# Post Count (N queries - one per user)
# ⚠️ N+1 Query detected!
```

#### Unused Eager Loading:
- ✅ Detects when you eager load but don't use the association
- ✅ Helps optimize queries

**Example:**
```ruby
# ❌ Bullet will flag this:
@users = User.includes(:posts)
@users.each { |u| puts u.name }  # Never uses posts

# Bullet detects:
# ⚠️ Unused eager loading detected: posts

# ✅ Fix:
@users = User.all  # Don't eager load if not needed
```

#### Counter Cache Opportunities:
- ✅ Suggests using counter cache instead of counting associations

**Example:**
```ruby
# ❌ Bullet will suggest:
user.posts.count  # Queries every time

# Bullet suggests:
# ⚠️ Counter cache opportunity: posts_count

# ✅ Fix:
# Add counter_cache: true to Post model
# user.posts_count  # Uses cached count
```

**Configuration:**
- `config/initializers/bullet.rb` - Main configuration
- `config/environments/test.rb` - Test environment settings
- `config/environments/development.rb` - Development settings

**CI Behavior:**
- `BULLET_RAISE: true` - **Fails tests if N+1 detected**
- `BULLET_ENABLED: true` - Enables Bullet
- `BULLET_ALERT: true` - Shows alerts

**What Bullet CANNOT Detect:**
- ❌ Code that never runs (needs execution)
- ❌ Static patterns (only runtime behavior)
- ❌ Code style issues
- ❌ Security vulnerabilities

---

### 4. Rails Test Suite - Functional Testing

**What it is:** Rails' built-in test framework (Minitest) that runs your application tests.

**When it runs:**
- ✅ In CI (`test` job)
- ✅ Manually: `bundle exec rails test`

**What it detects:**

#### Functional Issues:
- ✅ **Controller tests** - Request/response handling
- ✅ **Model tests** - Business logic, validations
- ✅ **Integration tests** - End-to-end workflows
- ✅ **Helper tests** - View helpers

#### What Tests Detect:
- ✅ Broken functionality
- ✅ Failed validations
- ✅ Routing errors
- ✅ View rendering issues
- ✅ Database errors
- ✅ **N+1 queries** (via Bullet integration)

**Example:**

```ruby
# test/controllers/widgets_controller_test.rb
test "should get index" do
  get widgets_url
  assert_response :success
  assert_not_nil assigns(:widgets)
end

# If this test runs code with N+1 queries:
# Bullet will detect and fail the test!
```

**Configuration:** `test/` directory, `test_helper.rb`

---

### 5. Build Check - Asset Compilation

**What it is:** Verifies that the application can be built and assets compiled for production.

**When it runs:**
- ✅ In CI (`build` job)
- ✅ Manually: `RAILS_ENV=production bundle exec rails assets:precompile`

**What it detects:**

#### Build Issues:
- ✅ **Asset compilation errors** - Missing files, syntax errors
- ✅ **Missing dependencies** - Gems, npm packages
- ✅ **Configuration errors** - Invalid settings
- ✅ **Initialization errors** - App can't start

**What it checks:**
- ✅ JavaScript/CSS compilation
- ✅ Asset pipeline configuration
- ✅ Production environment setup
- ✅ Application initialization

**Example failures:**

```ruby
# ❌ Build will fail if:
# - Missing JavaScript file
# - Syntax error in CSS
# - Missing gem
# - Invalid configuration

# ✅ Build passes if:
# - All assets compile successfully
# - App initializes without errors
```

---

## 📊 Detection Capabilities Matrix

| Issue Type | RuboCop | Brakeman | Bullet | Tests | Build |
|------------|---------|----------|--------|-------|-------|
| **Code Style** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Performance Patterns** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **N+1 Queries** | ⚠️ (patterns) | ❌ | ✅ (actual) | ✅ (via Bullet) | ❌ |
| **SQL Injection** | ❌ | ✅ | ❌ | ⚠️ (if tested) | ❌ |
| **XSS Vulnerabilities** | ❌ | ✅ | ❌ | ⚠️ (if tested) | ❌ |
| **Mass Assignment** | ❌ | ✅ | ❌ | ⚠️ (if tested) | ❌ |
| **Broken Functionality** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Build Errors** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Unused Eager Loading** | ❌ | ❌ | ✅ | ✅ (via Bullet) | ❌ |
| **Counter Cache Opportunities** | ❌ | ❌ | ✅ | ✅ (via Bullet) | ❌ |

**Legend:**
- ✅ = Detects this issue
- ⚠️ = Partially detects (patterns only, or if tested)
- ❌ = Does not detect

---

## 🔄 How Tools Work Together

### Example: Detecting a Bad Query Pattern

**Scenario:** Developer writes `@widgets = Widget.all` without pagination

**Detection flow:**

1. **RuboCop** (Static):
   - ⚠️ Might catch `.all.each` pattern
   - ❌ Won't catch `.all` alone (no rule for this)

2. **Brakeman** (Security):
   - ❌ Not a security issue

3. **Bullet** (Runtime):
   - ✅ **WILL detect** if code runs and causes N+1
   - ✅ **WILL fail test** if N+1 detected

4. **Tests** (Functional):
   - ✅ Runs the code
   - ✅ Bullet detects N+1 during test execution
   - ✅ Test fails if Bullet raises

5. **Build** (Compilation):
   - ✅ Code compiles fine

**Result:** Test fails → CI fails → Code blocked ✅

---

## 🎯 What Gets Blocked in CI

### Code That Gets Blocked:

1. **Style violations** (RuboCop)
   - Inconsistent formatting
   - Performance anti-patterns
   - Rails best practice violations

2. **Security vulnerabilities** (Brakeman)
   - SQL injection
   - XSS vulnerabilities
   - Mass assignment issues
   - Authentication/authorization flaws

3. **N+1 queries** (Bullet)
   - Actual N+1 queries detected at runtime
   - Unused eager loading
   - Counter cache opportunities (warnings)

4. **Broken functionality** (Tests)
   - Failed tests
   - Broken controllers/models
   - Integration failures

5. **Build failures** (Build Check)
   - Asset compilation errors
   - Missing dependencies
   - Configuration errors

---

## 🚀 Running Tools Locally

### Before Committing:

```bash
# Run all checks
bundle exec rubocop
bundle exec brakeman
BULLET_ENABLED=true bundle exec rails test

# Or use pre-commit hooks (if installed)
pre-commit run --all-files
```

### Individual Tools:

```bash
# RuboCop (with auto-fix)
bundle exec rubocop -a

# Brakeman (with report)
bundle exec brakeman --format json --output brakeman-report.json

# Tests with Bullet
BULLET_ENABLED=true BULLET_RAISE=true bundle exec rails test

# Build check
RAILS_ENV=production bundle exec rails assets:precompile
```

---

## 📝 Summary

### What's Monitored:

1. ✅ **Code Quality** - RuboCop (style, performance patterns)
2. ✅ **Security** - Brakeman (vulnerabilities)
3. ✅ **Query Performance** - Bullet (N+1 queries, eager loading)
4. ✅ **Functionality** - Tests (broken features)
5. ✅ **Build** - Asset compilation (deployment readiness)

### Key Tools:

- **RuboCop** - Catches patterns, enforces style
- **Brakeman** - Catches security vulnerabilities
- **Bullet** - **Most important for N+1 detection** (sees actual queries)
- **Tests** - Ensures functionality works
- **Build** - Ensures deployment readiness

### Most Important Tool for N+1 Detection:

**Bullet** - It's the only tool that detects **actual N+1 queries** at runtime. RuboCop only catches patterns, but Bullet sees real database queries happening.

---

## 🎓 Best Practices

1. **Run tools locally** before pushing
2. **Fix RuboCop violations** automatically when possible (`rubocop -a`)
3. **Write tests** that exercise database queries (so Bullet can detect N+1)
4. **Review Brakeman reports** for security issues
5. **Monitor CI failures** and fix issues promptly

---

**Your CI pipeline now has a streamlined, effective monitoring system focused on the tools that matter most!** 🎯
