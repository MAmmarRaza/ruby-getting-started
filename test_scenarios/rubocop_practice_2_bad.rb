# RuboCop Practice File 2 - Performance Issues (BAD CODE)
# This shows code with actual violations

class ReportGenerator
  def generate
    users = User.all  # No pagination - RuboCop might catch this
    users.each do |user|  # RuboCop WILL catch this (Rails/FindEach)
      posts = Post.where(user_id: user.id)  # N+1 query - RuboCop CANNOT catch this
      count = posts.count  # RuboCop might catch this (Performance/Count)
      puts "#{user.name}: #{count} posts"
    end
  end

  def generate_report
    orders = Order.all  # No limit - RuboCop might catch this
    total = 0
    orders.each do |order|  # RuboCop WILL catch this (Rails/FindEach)
      total += order.total
    end
    puts "Total: #{total}"
  end
end
