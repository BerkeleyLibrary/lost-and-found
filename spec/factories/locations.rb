FactoryBot.define do
  factory :location do
    location_name { 'unknown' }
    location_active { true }
    updated_by { 'Test' }
  end
end
