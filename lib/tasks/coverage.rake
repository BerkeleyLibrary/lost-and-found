desc 'Run all specs in spec directory, with coverage'
task :coverage do
  ENV['COVERAGE'] ||= 'true'
  # TODO: run all specs
  Rake::Task['spec:system'].invoke
  # Rake::Task[:spec].invoke
end
