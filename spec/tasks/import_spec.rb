require 'rails_helper'
require 'rake'

describe 'import task' do
  before(:all) { LostAndFound::Application.load_tasks if Rake::Task.tasks.empty? }

  describe 'invoke' do
    it 'passes args to the ItemCsvImport class' do
      importer = instance_double('ItemCsvImport')
      expect(ItemCsvImport).to receive(:new).with(
        label: 'label',
        cutoff_date: '2024-12-01',
        infile: 'tmp/input.csv',
        outfile: 'tmp/output.csv'
      ).and_return importer
      expect(importer).to receive(:import!)

      Rake::Task[:import].invoke(
        'label',
        'tmp/input.csv',
        'tmp/output.csv',
        '2024-12-01'
      )
    end
  end
end
