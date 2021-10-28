RSpec.shared_examples 'admin access is denied' do
  it 'disallows access to the admin home page' do
    visit(admin_path)
    expect(page).to have_content('Forbidden')
    expect(page).not_to have_content('Lost & Found - Administration')

    admin_links = [
      admin_users_path,
      admin_locations_path,
      admin_item_types_path,
      admin_purge_path
    ]
    admin_links.each do |link|
      expect(page).not_to have_link(href: link)
    end
  end

  it 'disallows purging items' do
    visit(admin_purge_path)
    expect(page).to have_content('Forbidden')
    expect(page).not_to have_content('Purge items')
  end

  it 'disallows editing claimed items' do
    # TODO: replace magic number with enum
    status_claimed = 3

    item = Item.take
    item.update(itemStatus: status_claimed, claimedBy: 'Mr. Magoo')

    edit_path = edit_item_path(item.id)
    visit(edit_path)

    expect(page).to have_content('Forbidden')
    expect(page).not_to have_content('Update item')
  end

  context 'users' do
    before(:each) do
      ensure_all_users!
    end

    it 'disallows access to the add/edit users page' do
      visit(admin_users_path)
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Add/Edit Lost & Found Users')
    end

    it 'disallows editing a user' do
      u = User.take
      edit_path = edit_user_path(u.id)
      visit(edit_path)
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Edit user')
    end

    it 'disallows toggling the status of a user' do
      u = User.take
      expect(u.user_active).to eq(true) # just to be sure

      toggle_status_path = toggle_user_status_path(u.id)
      visit(toggle_status_path)

      expect(page).to have_content('Forbidden')
      expect(page).not_to have_link('Activate', href: toggle_status_path)

      u.reload
      expect(u.user_active).to eq(true)
    end
  end

  context 'locations' do
    before(:each) do
      # We assume the calling suite already created location data
      expect(Location.exists?).to eq(true)
    end

    it 'disallows access to the add/edit locations page' do
      visit(admin_locations_path)
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Add/Edit Lost & Found Locations')
    end

    it 'disallows editing a location' do
      l = Location.take
      edit_path = edit_location_path(l.id)
      visit(edit_path)
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Edit location')
    end

    it 'disallows toggling the status of a location' do
      l = Location.take
      expect(l.location_active).to eq(true) # just to be sure

      toggle_status_path = toggle_location_status_path(l.id)
      visit(toggle_status_path)

      expect(page).to have_content('Forbidden')
      expect(page).not_to have_link('Activate', href: toggle_status_path)

      l.reload
      expect(l.location_active).to eq(true)
    end
  end

  context 'item types' do
    before(:each) do
      # We assume the calling suite already created item type data
      expect(ItemType.exists?).to eq(true)
    end

    it 'disallows access to the add/edit item types page' do
      visit(admin_item_types_path)
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Add/Edit Lost & Found Item Types')
    end

    it 'disallows editing a item type' do
      t = ItemType.take
      edit_path = edit_item_type_path(t.id)
      visit(edit_path)
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Edit item type')
    end

    it 'disallows toggling the status of a item type' do
      t = ItemType.take
      expect(t.type_active).to eq(true) # just to be sure

      toggle_status_path = toggle_item_type_status_path(t.id)
      visit(toggle_status_path)

      expect(page).to have_content('Forbidden')
      expect(page).not_to have_link('Activate', href: toggle_status_path)

      t.reload
      expect(t.type_active).to eq(true)
    end
  end
end
