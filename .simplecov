require 'simplecov-rcov'

SimpleCov.start 'rails' do
  add_filter %w[/app/channels/ /bin/ /db/ /spec/ /test/ /lib/]
  coverage_dir 'artifacts'
  formatter SimpleCov::Formatter::RcovFormatter
  minimum_coverage 100
end
