describe 'RSpec test group' do
  it 'by default, PaperTrail will be turned off' do
    expect(PaperTrail).to_not be_enabled
  end

  it 'can be turned on at the `it` or `describe` level', versioning: true do
    expect(PaperTrail).to be_enabled
  end
end
