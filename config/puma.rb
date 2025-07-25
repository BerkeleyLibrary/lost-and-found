# frozen_string_literal: true

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 3)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue if ENV['SOLID_QUEUE_IN_PUMA']

pidfile ENV['PIDFILE'] if ENV['PIDFILE']
