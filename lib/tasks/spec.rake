namespace :spec do
  desc 'Run bundle-audit'
  task :audit do |_t, _args|
    system 'bundle-audit update'
    system 'bundle-audit check --ignore CVE-2015-9284 --verbose'
  end

  desc 'Run Brakeman'
  task :brakeman do |_t, _args|
    require 'brakeman'
    Brakeman.run '.'
  end

  desc 'Run all specs plus security checks'
  multitask all: %w(spec brakeman audit)
end
