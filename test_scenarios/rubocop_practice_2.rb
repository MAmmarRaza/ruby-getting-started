# RuboCop Practice File 2 - Performance Issues (FIXED)
# Run: bundle exec rubocop test_scenarios/rubocop_practice_2.rb

class ReportGenerator
  def generate
    # Fixed: Eager load posts to prevent N+1 queries
    User.includes(:posts).find_each do |user|
      # Fixed: Use size since posts are already loaded
      count = user.posts.size
      puts "#{user.name}: #{count} posts"
    end
  end

  def generate_report
    # Fixed: Use find_each for large datasets (loads in batches)
    total = 0
    Order.find_each do |order|
      total += order.total
    end
    puts "Total: #{total}"
  end
end
