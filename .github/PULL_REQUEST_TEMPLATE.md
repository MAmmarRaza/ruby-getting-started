## Description
<!-- Describe your changes in detail -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Performance improvement
- [ ] Refactoring
- [ ] Documentation update

## Database Changes
- [ ] No database changes
- [ ] Migration included
- [ ] Data migration included

## Query Optimization Checklist
- [ ] No `.all` without `.limit` or pagination
- [ ] Associations are eager loaded (`.includes`, `.preload`, `.eager_load`)
- [ ] Used `.find_each` or `.find_in_batches` for large datasets
- [ ] Used `.pluck` when only specific columns needed
- [ ] No N+1 queries introduced
- [ ] Queries tested with Bullet enabled

## Testing
- [ ] Tests added/updated
- [ ] All tests pass locally
- [ ] Tested on staging environment
- [ ] No Bullet warnings

## Security
- [ ] No hardcoded credentials
- [ ] Strong parameters used
- [ ] Brakeman scan passes
- [ ] No SQL injection risks

## Performance
- [ ] Database indexes added if needed
- [ ] No queries in loops
- [ ] Pagination implemented for list views
- [ ] Caching considered for expensive operations

## Code Quality
- [ ] RuboCop passes
- [ ] Code follows Rails conventions
- [ ] No code smells detected

## Review Notes
<!-- Add any specific areas you'd like reviewers to focus on -->
