require 'mini_mime'

FactoryBot.define do
  factory :item do
    transient { image_path { nil } }

    date_found { Date.current - 1.days }
    found_at { Time.current }
    found_by { 'Testy McTestface' }
    status { 1 } # TODO: replace magic number with enum
    entered_by { 'Test' }
    updated_by { 'Test' }
    where_found { 'Somewhere' }

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
