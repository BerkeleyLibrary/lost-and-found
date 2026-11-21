require 'rails_helper'

describe ItemsController, type: :request do
  attr_reader :user
  attr_reader :items

  before(:each) do
    @items = []

    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    locations = ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc.downcase) }
    item_types = ['Pencil', 'Pen', 'Trapper Keeper'].map { |it| create(:item_type, type_name: it.downcase, type_description: "a #{it.downcase}") }
    locations.each_with_index do |loc, i|
      item_types.each_with_index do |type, j|
        items << create(
          :item,
          item_type: type.type_name,
          description: "description of #{type.type_name} found in #{loc.location_name}",
          image_path: File.join('spec/data/images', "#{type.type_name.titleize}.jpg"),
          date_found: (Date.current - j.months - (i + 1).days),
          location: loc.location_name
        )
      end
    end

    @user = mock_login(:admin)
  end

  describe 'create/update' do
    let(:description) { 'unidentified object' }
    let(:found_by) { 'Mr. Magoo' }
    let(:where_found) { 'New Jersey' }
    let(:test_time) { Time.zone.local(2025, 12, 3, 11) }

    include_context 'with a running test clock'

    attr_reader :count_before
    attr_reader :item_type
    attr_reader :item_type_name
    attr_reader :location
    attr_reader :location_name
    attr_reader :date_found
    attr_reader :date_found_str
    attr_reader :datetime_found
    attr_reader :time_found_str

    before(:each) do
      @count_before = Item.count

      @item_type = ItemType.take
      @location = Location.take
      @date_found = Date.current - 1
      @date_found_str = date_found.strftime('%Y-%m-%d') # TODO: standardize date formats

      @time_found_str = '23:15'
      @datetime_found = Time.zone.parse("#{date_found_str} #{time_found_str}")

      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      @item_type_name = item_type.type_name.capitalize

      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      @location_name = location.location_name.capitalize
    end

    describe :create do
      it 'creates an item' do
        params = {
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str,
          time_found: time_found_str
        }

        post(items_path, params: params)
        expect(response).to be_successful

        item = Item.find_by(description: description)
        expect(item.item_type).to eq(item_type.type_name)
        expect(item.location).to eq(location.location_name)
        expect(item.found_by).to eq(found_by)
        expect(item.where_found).to eq(where_found)
        expect(item.date_found.to_date).to eq(date_found.to_date)
        expect(item.datetime_found).to eq(datetime_found)

        expect(Item.count).to eq(1 + count_before)
      end

      it 'requires a description' do
        params = {
          item_type: item_type.type_name,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a type' do
        params = {
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a location' do
        params = {
          item_type: item_type.type_name,
          description: description,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a date found' do
        params = {
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a place found' do
        params = {
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          date_found: date_found_str
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end
    end

    describe :update do
      attr_reader :item
      attr_reader :previously_updated_at
      attr_reader :update_path

      before(:each) do
        @item = items.last
        @previously_updated_at = item.updated_at

        @update_path = item_update_path(id: item.id)
      end

      it 'updates an item' do
        params = {
          id: item.id,
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(update_path, params: params)
        expect(response).to redirect_to item_url(@item)

        item.reload
        expect(item.updated_at).not_to eq(previously_updated_at)

        expect(item.item_type).to eq(item_type.type_name)
        expect(item.location).to eq(location.location_name)
        expect(item.found_by).to eq(found_by)
        expect(item.where_found).to eq(where_found)
        expect(item.date_found.to_date).to eq(date_found.to_date)
      end

      it 'requires a description' do
        params = {
          id: item.id,
          item_type: item_type.type_name,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a type' do
        params = {
          id: item.id,
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a location' do
        params = {
          id: item.id,
          item_type: item_type.type_name,
          description: description,
          found_by: found_by,
          where_found: where_found,
          date_found: date_found_str
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a date found' do
        params = {
          id: item.id,
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a place found' do
        params = {
          id: item.id,
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          date_found: date_found_str
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end
    end

    describe 'daylight saving transitions' do
      let(:valid_params) do
        {
          item_type: item_type.type_name,
          description: description,
          location: location.location_name,
          found_by: found_by,
          where_found: where_found,
          time_found: '23:15'
        }
      end

      shared_examples 'stores the entered local time' do |date, time, expected_utc|
        it 'creates an item at the entered local time' do
          post(items_path, params: valid_params.merge(date_found: date, time_found: time))

          expect(response).to be_successful
          expect(Item.find_by!(description: description).datetime_found.utc).to eq(expected_utc)
        end

        it 'updates an item to the entered local time' do
          item = items.last
          post(item_update_path(id: item.id), params: valid_params.merge(id: item.id, date_found: date, time_found: time))

          expect(response).to redirect_to item_url(item)
          expect(item.reload.datetime_found.utc).to eq(expected_utc)
        end
      end

      shared_examples 'rejects a skipped local time' do |date, time|
        let(:invalid_params) { valid_params.merge(date_found: date, time_found: time) }

        it 'does not create an item and explains the error' do
          expect { post(items_path, params: invalid_params) }.not_to change(Item, :count)

          expect(response).to have_http_status(422)
          expect(response.body).to include('Time found does not exist in Pacific time')
          expect(Nokogiri::HTML(response.body).at_css('input[name="time_found"]')['value']).to eq(time)
        end

        it 'does not change an existing item and explains the error' do
          item = items.last
          previous_attributes = item.reload.attributes.slice('description', 'datetime_found', 'updated_at')
          post(item_update_path(id: item.id), params: invalid_params.merge(id: item.id))

          expect(response).to have_http_status(422)
          expect(response.body).to include('Time found does not exist in Pacific time')
          expect(Nokogiri::HTML(response.body).at_css('input[name="time_found"]')['value']).to eq(time)
          expect(item.reload.attributes.slice('description', 'datetime_found', 'updated_at')).to eq(previous_attributes)
        end
      end

      context 'when daylight saving time starts' do
        let(:test_time) { Time.zone.local(2025, 3, 10, 11) }

        it_behaves_like 'stores the entered local time', '2025-03-09', '23:15', Time.utc(2025, 3, 10, 6, 15)
        it_behaves_like 'rejects a skipped local time', '2025-03-09', '02:30'
      end

      context 'when daylight saving time ends' do
        let(:test_time) { Time.zone.local(2025, 11, 3, 11) }

        it_behaves_like 'stores the entered local time', '2025-11-02', '23:15', Time.utc(2025, 11, 3, 7, 15)
        it_behaves_like 'stores the entered local time', '2025-11-02', '01:30', Time.utc(2025, 11, 2, 8, 30)

        it 'explains the first-occurrence rule on both item forms' do
          get(new_item_path)
          expect(response.body).to include('first occurrence (Pacific Daylight Time)')

          get(edit_item_path(items.last))
          expect(response.body).to include('first occurrence (Pacific Daylight Time)')
        end
      end
    end
  end
end
