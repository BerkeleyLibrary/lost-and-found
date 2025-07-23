require 'rails_helper'

describe 'items/show.html.erb', type: :view do
  before do
    location = create(:location, location_name: 'doe')
    type = create(:item_type, type_name: 'trapper keeper', type_description: 'A Trapper Keeper')
    assign :locations_layout, [%w[Doe doe]]
    assign :item_type_layout, [['Trapper Keeper', 'trapper keeper']]
    assign :item, create(:item, item_type: type.type_name, date_found: Date.today, location: location.location_name,
                                description: 'description')
  end

  it 'renders without error' do
    render
    expect(rendered).to have_content 'Item history'
  end

  context 'without a value for found_by' do
    before { view_assigns[:item].update(found_by: nil) }

    it 'renders an unknown value' do
      render
      expect(rendered).to have_content "Found by\n  No one"
    end
  end

  context 'with a value for found_by' do
    before { view_assigns[:item].update(found_by: 'DZ') }

    it 'renders the value' do
      render
      expect(rendered).to have_content "Found by\n  DZ"
    end
  end

  context 'without an image' do
    before { view_assigns[:item].image.purge if view_assigns[:item].image.attached? }

    it 'renders a placeholder' do
      render
      expect(rendered).to have_content 'No image'
    end
  end

  with_versioning do
    context 'with an image' do
      before do
        view_assigns[:item].image.attach(io: File.open('spec/data/images/Trapper Keeper.jpg'),
                                         filename: 'Trapper Keeper.jpg', content_type: 'image/jpeg', identify: false)
        view_assigns[:item].update!(image_url: 'spec/data/images/Trapper Keeper.jpg')
      end

      it 'renders the image' do
        render
        assert_select 'img[class=preview_image][src=?]', url_for(view_assigns[:item].image)
      end

      it 'has the image shown in version history' do
        render
        expect(rendered).to have_content 'New image uploaded'
      end
    end
  end

  context 'without changes' do
    before do
      now = DateTime.now
      view_assigns[:item].update(created_at: now, updated_at: now)
    end

    it 'renders that the item has not been updated' do
      render
      expect(rendered).to have_content "Last updated\n    None"
    end
  end
end
