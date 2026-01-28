Datadog.configure do |c|
  c.service = 'ruby-app'
  c.env = 'production'

  # Activate integrations (Rails, Redis, Sidekiq, etc.)
  c.tracing.instrument :rails
  c.tracing.instrument :redis if defined?(Redis)
end