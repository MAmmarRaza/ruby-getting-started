namespace :quality do
  desc "Run all quality checks"
  task all: [:rubocop, :brakeman, :test]

  desc "Run RuboCop"
  task :rubocop do
    puts "Running RuboCop..."
    sh "bundle exec rubocop" do |ok, res|
      unless ok
        puts "❌ RuboCop found issues. Please fix them before committing."
        exit res.exitstatus
      end
    end
    puts "✅ RuboCop passed!"
  end

  desc "Run Brakeman security scan"
  task :brakeman do
    puts "Running Brakeman..."
    sh "bundle exec brakeman --no-pager --quiet" do |ok, res|
      unless ok
        puts "❌ Brakeman found security issues. Please review them."
        exit res.exitstatus
      end
    end
    puts "✅ Brakeman passed!"
  end

  desc "Run tests"
  task :test do
    puts "Running tests..."
    sh "bundle exec rails test" do |ok, res|
      unless ok
        puts "❌ Tests failed. Please fix them before committing."
        exit res.exitstatus
      end
    end
    puts "✅ Tests passed!"
  end

  desc "Check for N+1 queries in code"
  task :check_queries do
    puts "Checking for potential N+1 queries..."
    
    # Check for common N+1 patterns
    issues = []
    
    Dir.glob("app/**/*.rb").each do |file|
      content = File.read(file)
      lines = content.split("\n")
      
      lines.each_with_index do |line, index|
        # Check for .all without limit
        if line.match?(/\.all\s*$/) && !line.match?(/\.limit|\.find_each|\.find_in_batches/)
          issues << "#{file}:#{index + 1} - Using .all without limit/pagination"
        end
        
        # Check for .each on ActiveRecord relations
        if line.match?(/\.each\s*\{/) && !line.match?(/\.find_each/)
          issues << "#{file}:#{index + 1} - Consider using .find_each for large datasets"
        end
        
        # Check for missing includes/joins
        if line.match?(/\.where|\.find_by/) && !content.match?(/\.includes|\.joins|\.preload|\.eager_load/)
          # This is a simple check - might have false positives
          if content.match?(/\.(name|email|title|description)/)
            issues << "#{file}:#{index + 1} - Potential N+1 - check if associations need eager loading"
          end
        end
      end
    end
    
    if issues.any?
      puts "⚠️  Potential query issues found:"
      issues.each { |issue| puts "  - #{issue}" }
      puts "\nPlease review and fix these issues."
      exit 1
    else
      puts "✅ No obvious N+1 query patterns detected."
    end
  end
end

# Run quality checks before tests
task test: "quality:check_queries"
