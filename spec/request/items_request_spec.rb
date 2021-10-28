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
          itemType: type.type_name,
          itemDescription: "description of #{type.type_name} found in #{loc.location_name}",
          image_path: File.join('spec/data/images', "#{type.type_name}.jpg"),
          itemDate: (Date.current - j.months - (i + 1).days),
          itemLocation: loc.location_name
        )
      end
    end

    @user = mock_login(:admin)
  end

  describe 'create/update' do
    let(:description) { 'unidentified object' }
    let(:found_by) { 'Mr. Magoo' }
    let(:where_found) { 'New Jersey' }

    attr_reader :count_before
    attr_reader :item_type
    attr_reader :item_type_name
    attr_reader :location
    attr_reader :location_name
    attr_reader :when_found
    attr_reader :item_date_str

    before(:each) do
      @count_before = Item.count

      @item_type = ItemType.take
      @location = Location.take
      @when_found = Date.current - 1
      @item_date_str = when_found.strftime("%Y-%m-%d") # TODO: standardize date formats

      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      @item_type_name = item_type.type_name.capitalize

      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      @location_name = location.location_name.capitalize
    end

    describe :create do
      it 'creates an item' do
        params = {
          itemType: item_type.type_name,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(items_path, params: params)
        expect(response).to be_successful

        item = Item.find_by(itemDescription: description)
        expect(item.itemType).to eq(item_type.type_name)
        expect(item.itemLocation).to eq(location.location_name)
        expect(item.itemFoundBy).to eq(found_by)
        expect(item.whereFound).to eq(where_found)
        expect(item.itemDate.to_date).to eq(when_found.to_date)

        expect(Item.count).to eq(1 + count_before)
      end

      it 'requires a description' do
        params = {
          itemType: item_type.type_name,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a type' do
        params = {
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a location' do
        params = {
          itemType: item_type.type_name,
          itemDescription: description,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a date found' do
        params = {
          itemType: item_type.type_name,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found
        }

        post(items_path, params: params)
        expect(Item.count).to eq(count_before)
      end

      it 'requires a place found' do
        params = {
          itemType: item_type.type_name,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          itemDate: item_date_str,
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
          itemType: item_type.type_name,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(update_path, params: params)
        expect(response).to be_successful
        expect(response.body).to include('item updated')

        item.reload
        expect(item.updated_at).not_to eq(previously_updated_at)

        expect(item.itemType).to eq(item_type.type_name)
        expect(item.itemLocation).to eq(location.location_name)
        expect(item.itemFoundBy).to eq(found_by)
        expect(item.whereFound).to eq(where_found)
        expect(item.itemDate.to_date).to eq(when_found.to_date)
      end

      it 'requires a description' do
        params = {
          id: item.id,
          itemType: item_type.type_name,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a type' do
        params = {
          id: item.id,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a location' do
        params = {
          id: item.id,
          itemType: item_type.type_name,
          itemDescription: description,
          itemFoundBy: found_by,
          whereFound: where_found,
          itemDate: item_date_str,
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a date found' do
        params = {
          id: item.id,
          itemType: item_type.type_name,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          whereFound: where_found
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end

      it 'requires a place found' do
        params = {
          id: item.id,
          itemType: item_type.type_name,
          itemDescription: description,
          itemLocation: location.location_name,
          itemFoundBy: found_by,
          itemDate: item_date_str,
        }

        post(update_path, params: params)
        expect(item.updated_at).to eq(previously_updated_at)
      end
    end
  end
end
