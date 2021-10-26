require 'mini_mime'

FactoryBot.define do
  factory :item do
    transient { image_path { nil } }

    itemDate { Date.current }
    itemFoundAt { Time.current }
    itemFoundBy { 'Testy McTestface' }
    itemStatus { 1 } # TODO: replace magic number with enum
    itemEnteredBy { 'Test' }
    itemUpdatedBy { 'Test' }
    whereFound { 'Somewhere' }

    after(:build) do |item, ev|
      next unless (image_path = ev.image_path)

      item.image.attach(
        io: File.open(image_path, 'rb'),
        filename: File.basename(image_path),
        content_type: MiniMime.lookup_by_filename(image_path)
      )
    end
  end
end
