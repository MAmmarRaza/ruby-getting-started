# Query Review Checklist

Use this checklist when reviewing code for database query issues, especially before merging PRs.

## 🔍 Pre-Merge Query Review

### 1. Controller Actions
- [ ] No `Model.all` without limit or pagination
- [ ] Associations are eager loaded before iteration
- [ ] Pagination implemented for index actions
- [ ] No queries inside loops

### 2. Model Methods
- [ ] No N+1 queries in scopes
- [ ] Counter caches used instead of `.count` on associations
- [ ] `.pluck` used when only specific columns needed
- [ ] `.exists?` used instead of `.count > 0`

### 3. Views
- [ ] No queries in views (move to controller)
- [ ] Associations pre-loaded before rendering
- [ ] No `.each` on ActiveRecord relations without eager loading

### 4. Common Patterns to Check

#### ❌ Red Flags:
```ruby
# BAD: Loading all records
Widget.all

# BAD: N+1 query
@widgets.each { |w| w.user.name }

# BAD: Query in loop
users.each { |u| u.posts.count }

# BAD: Missing eager loading
@posts = Post.where(published: true)
# Later in view: @posts.each { |p| p.author.name }
```

#### ✅ Good Patterns:
```ruby
# GOOD: Pagination
Widget.order(created_at: :desc).limit(20).offset(page * 20)

# GOOD: Eager loading
@widgets = Widget.includes(:user).limit(20)

# GOOD: Counter cache
user.posts_count  # Instead of user.posts.count

# GOOD: Batch processing
Widget.find_each { |w| process(w) }
```

### 5. Testing Checklist
- [ ] Run tests with `BULLET_ENABLED=true`
- [ ] Check test logs for query count
- [ ] Verify no unexpected queries in test output
- [ ] Performance tests added for critical paths

### 6. Staging Verification
- [ ] Review staging logs for slow queries
- [ ] Check query count per request
- [ ] Verify response times are acceptable
- [ ] No Bullet warnings in staging

### 7. Production Monitoring
After deployment, monitor:
- [ ] Slow query logs
- [ ] Database connection pool usage
- [ ] Response times
- [ ] Error rates

## 🛠️ Tools to Use

### Local Development:
```bash
# Enable Bullet
BULLET_ENABLED=true rails server

# Check query patterns
# Note: Custom query checker removed - use Bullet instead (runs automatically in tests)
# BULLET_ENABLED=true bundle exec rails test

# Review logs
tail -f log/development.log | grep "SELECT"
```

### CI/CD:
- GitHub Actions runs Bullet in test environment
- Query pattern checks run automatically
- Brakeman scans for security issues

### Production:
- Heroku Postgres Insights
- Datadog APM (configured)
- Application logs

## 📊 Query Performance Thresholds

| Query Type | Acceptable Time | Action Required |
|------------|----------------|-----------------|
| Simple SELECT | < 10ms | OK |
| JOIN queries | < 50ms | Review if > 30ms |
| Complex queries | < 100ms | Optimize if > 50ms |
| Any query | > 100ms | **BLOCK DEPLOYMENT** |

## 🚨 Blocking Issues

These issues **MUST** be fixed before merge:
- N+1 queries detected by Bullet
- Queries > 100ms
- `.all` without pagination on tables with > 1000 records
- Missing indexes on frequently queried columns
- Queries in loops

## ✅ Approval Criteria

Before approving a PR:
1. All CI checks pass
2. No Bullet warnings
3. Query review checklist completed
4. Staging tested (if applicable)
5. Performance acceptable

---

**Remember:** A few extra minutes in review saves hours of debugging in production! 🛡️
