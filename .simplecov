require 'simplecov-rcov'

SimpleCov.start 'rails' do
  add_filter %w[/app/channels/ /bin/ /db/ /spec/ /test/ /lib/]
  coverage_dir 'artifacts'
  formatter SimpleCov::Formatter::RcovFormatter
  minimum_coverage 100

  # Ensures that all branches are executed (if ... else ... end)
  enable_coverage :branch
  # Allows for coverage testing on view files as well.
  enable_coverage_for_eval
end
