# Developer Guidelines - Preventing Bad Code Deployment

## 🚨 Critical Rules Before Deployment

### 1. **Database Query Rules** ⚠️ HIGHEST PRIORITY

#### ❌ NEVER DO THIS:
```ruby
# BAD: Loads all records into memory
@widgets = Widget.all

# BAD: N+1 query - loads associations one by one
@widgets.each { |w| w.user.name }

# BAD: Multiple queries in a loop
users.each { |u| u.posts.count }
```

#### ✅ ALWAYS DO THIS:
```ruby
# GOOD: Use pagination
@widgets = Widget.order(created_at: :desc).limit(20).offset(params[:page].to_i * 20)

# GOOD: Eager load associations
@widgets = Widget.includes(:user).limit(20)

# GOOD: Use counter cache or pluck
@post_counts = Post.group(:user_id).count
```

#### Query Checklist Before Committing:
- [ ] No `.all` without `.limit` or pagination
- [ ] Associations are eager loaded with `.includes`, `.preload`, or `.eager_load`
- [ ] Use `.find_each` or `.find_in_batches` for large datasets
- [ ] Use `.pluck` when you only need specific columns
- [ ] Use `.exists?` instead of `.count > 0` when checking existence
- [ ] Use `.size` instead of `.count` when association is already loaded

### 2. **Code Quality Standards**

#### Before Every Commit:
```bash
# Run these commands locally:
bundle exec rubocop
bundle exec brakeman
bundle exec rails test
```

#### RuboCop Rules:
- Maximum method length: 30 lines
- Maximum class length: 200 lines
- Maximum ABC complexity: 20
- Use single quotes for strings
- Follow Rails conventions

### 3. **Testing Requirements**

#### Minimum Test Coverage:
- [ ] All new controllers have tests
- [ ] All new models have tests
- [ ] Critical business logic is tested
- [ ] Edge cases are covered

#### Test Checklist:
- [ ] Tests pass locally
- [ ] No N+1 queries detected (Bullet will catch this)
- [ ] Tests run in CI before merge

### 4. **Security Checklist**

#### Before Deployment:
- [ ] No hardcoded credentials
- [ ] No SQL injection vulnerabilities (use parameterized queries)
- [ ] No XSS vulnerabilities (use `sanitize` or `html_safe` appropriately)
- [ ] CSRF protection enabled
- [ ] Strong parameters used in controllers
- [ ] Brakeman scan passes

### 5. **Performance Checklist**

#### Database:
- [ ] Indexes added for frequently queried columns
- [ ] No queries in loops
- [ ] Pagination implemented for list views
- [ ] Database queries logged and reviewed

#### General:
- [ ] No unnecessary database queries
- [ ] Caching considered for expensive operations
- [ ] Background jobs used for long-running tasks
- [ ] No blocking operations in request cycle

### 6. **Code Review Process**

#### For Reviewers:
1. **Check for N+1 queries:**
   - Look for `.all`, `.each` on ActiveRecord relations
   - Check for missing `.includes` on associations
   - Review query logs if available

2. **Check for security issues:**
   - Review Brakeman output
   - Check for SQL injection risks
   - Verify strong parameters usage

3. **Check code quality:**
   - Review RuboCop violations
   - Check test coverage
   - Verify error handling

4. **Performance review:**
   - Check for pagination
   - Verify indexes are present
   - Review query complexity

#### Required Approvals:
- At least 1 senior developer approval required
- CI must pass all checks
- No blocking issues from Brakeman or RuboCop

### 7. **Staging Environment Testing**

#### Before Production Deployment:
- [ ] Tested on staging environment
- [ ] Database queries reviewed in staging logs
- [ ] Performance tested with realistic data
- [ ] No errors in staging logs
- [ ] Bullet warnings reviewed and fixed

### 8. **Common Anti-Patterns to Avoid**

#### ❌ Anti-Patterns:
```ruby
# Loading all records
Widget.all.each { |w| process(w) }

# N+1 queries
@users.each { |u| u.posts.count }

# Missing indexes
User.where(email: params[:email]) # if email not indexed

# Unnecessary queries
if User.exists?(id: user_id)
  user = User.find(user_id)  # Query twice!
end

# Inefficient counting
Post.where(user_id: user.id).count  # Use counter_cache instead
```

#### ✅ Best Practices:
```ruby
# Use find_each for large datasets
Widget.find_each { |w| process(w) }

# Eager load associations
@users = User.includes(:posts).all
@users.each { |u| u.posts.size }  # No additional queries

# Use exists? efficiently
user = User.find_by(id: user_id)  # Single query

# Use counter cache
user.posts_count  # Pre-calculated
```

### 9. **CI/CD Pipeline**

#### What Happens Automatically:
1. **On Pull Request:**
   - RuboCop runs (blocks if fails)
   - Brakeman security scan (blocks if fails)
   - Tests run with Bullet enabled (blocks if N+1 detected)
   - Query pattern check runs

2. **Before Merge:**
   - All checks must pass
   - No blocking issues allowed

3. **On Main Branch Push:**
   - Full test suite runs
   - Security scan runs
   - Build verification
   - Deployment gate checks

### 10. **Monitoring in Production**

#### What to Monitor:
- Slow queries (queries > 100ms)
- N+1 query patterns
- Database connection pool exhaustion
- Memory usage
- Response times

#### Tools:
- Heroku Postgres Insights
- Datadog APM (already configured)
- Application logs
- New Relic (if configured)

### 11. **Emergency Procedures**

#### If Bad Code Gets Deployed:
1. **Immediate Actions:**
   - Rollback immediately: `heroku rollback`
   - Check logs: `heroku logs --tail`
   - Identify the issue

2. **Investigation:**
   - Review recent commits
   - Check CI logs to see why it passed
   - Identify root cause

3. **Prevention:**
   - Add test case for the issue
   - Update CI checks if needed
   - Document the incident

### 12. **Resources**

- [Rails Query Optimization Guide](https://guides.rubyonrails.org/active_record_querying.html)
- [Bullet Gem Documentation](https://github.com/flyerhzm/bullet)
- [RuboCop Rails Rules](https://docs.rubocop.org/rubocop-rails/)
- [Brakeman Security Scanner](https://brakemanscanner.org/)

---

## Quick Reference Commands

```bash
# Run all quality checks
bundle exec rake quality:all

# Check for N+1 queries
bundle exec rake quality:check_queries

# Run RuboCop
bundle exec rubocop

# Run Brakeman
bundle exec brakeman

# Run tests with Bullet
BULLET_ENABLED=true bundle exec rails test

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Check specific file
bundle exec rubocop app/controllers/widgets_controller.rb
```

---

**Remember:** It's better to catch issues in CI than in production! 🛡️
