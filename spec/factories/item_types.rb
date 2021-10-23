FactoryBot.define do
  factory :item_type do
    type_name { 'unknown' }
    type_description { 'No description' }
    type_active { true }
    updated_by { 'Test' }
  end
end
