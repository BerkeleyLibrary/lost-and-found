# frozen_string_literal: true

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

bind ENV.fetch('PUMA_BIND', 'tcp://0.0.0.0:3000')
environment ENV.fetch('RAILS_ENV', 'development')
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
plugin :tmp_restart
