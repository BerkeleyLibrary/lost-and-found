desc 'Imports items from a CSV file'
task :import, %i[label infile outfile cutoff_date] => :environment do |_task, args|
  label = args[:label] || '#LIBIT-7002'
  infile = args[:infile] || Rails.root.join('tmp', 'items.csv')
  outfile = args[:outfile] || Rails.root.join('tmp', "#{File.basename(infile, '.csv')}-processed.csv")
  cutoff_date = args[:cutoff_date] || '2024-11-15'

  import = ItemCsvImport.new(
    label: label,
    earliest: cutoff_date,
    infile: infile,
    outfile: outfile
  )
  import.import!
end
