FactoryBot.define do
  factory :item do
    transient { image_path { nil } }

    itemDate { Date.current }
    itemFoundAt { Time.current }
    itemStatus { 1 } # TODO: replace magic number with enum
    itemEnteredBy { 'Test' }

    after(:build) do |item, ev|
      next unless ev.image_path

      # TODO: get item image in here
    end
  end
end
