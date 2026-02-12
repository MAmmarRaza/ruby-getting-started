if defined?(Bullet)
  Bullet.enable = true
  
  # Alert in development
  Bullet.alert = Rails.env.development?
  
  # Console notifications
  Bullet.console = Rails.env.development?
  
  # Rails logger
  Bullet.rails_logger = true
  
  # Raise error in test environment to fail CI
  Bullet.raise = Rails.env.test?
  
  # Add stacktrace to help identify where N+1 queries occur
  Bullet.add_footer = true
  
  # Detect N+1 queries
  Bullet.n_plus_one_query_enable = true
  
  # Detect unused eager loading
  Bullet.unused_eager_loading_enable = true
  
  # Detect counter cache
  Bullet.counter_cache_enable = true
  
  # Skip specific paths if needed
  # Bullet.skip_html_injection = true
end
