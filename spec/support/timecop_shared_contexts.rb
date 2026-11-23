require 'timecop'

RSpec.shared_context 'with a running test clock' do
  around(:example) do |example|
    Timecop.travel(test_time) { example.run }
  end
end

RSpec.shared_context 'with a frozen test clock' do
  around(:example) do |example|
    Timecop.freeze(test_time) { example.run }
  end
end
