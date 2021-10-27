require 'rails_helper'

describe User, type: :model do
  before(:each) do
    ensure_all_users!
  end

  describe :user_role do
    it 'matches the flags' do
      flags = {
        'Administrator' => :administrator?,
        'Staff' => :staff?,
        'Read-only' => :read_only?
      }

      aggregate_failures do
        User.find_each do |user|
          flags.each do |role_value, flag|
            expected_value = user.user_role == role_value
            flag_value = user.send(flag)
            expect(flag_value).to eq(expected_value), "Role is #{user.user_role.inspect}, but #{flag} returned #{flag_value}"
          end
        end

        flags.each do |role_value, flag|
          users_for_role = User.where(user_role: role_value)
          expect(users_for_role.exists?).to eq(true)

          users_for_role.find_each do |user|
            flag_value = user.send(flag)
            expect(flag_value).to eq(true)
          end
        end
      end
    end

    it 'defaults to nil' do
      user = User.new(uid: 12345, user_name: 'Testy McTestface', user_active: false)
      expect(user.user_role).to eq(nil)
    end
  end

  describe :authenticated? do
    it 'returns true for persisted users with UIDs' do
      User.find_each do |user|
        expect(user.authenticated?).to eq(true)
      end
    end

    it 'returns true for non-persisted users with UIDs' do
      user = User.new(uid: 12345)
      expect(user.authenticated?).to eq(true)
    end

    it 'returns false for users without UIDs' do
      user = User.new
      expect(user.authenticated?).to eq(false)
    end
  end

  describe :authorized? do
    it 'returns true for persisted users with roles' do
      User.find_each do |user|
        expect(user.authorized?).to eq(true) if user.user_role
      end
    end

    it 'returns false for non-persisted users with roles' do
      user = User.new(uid: 12345, user_role: :administrator, user_active: true)
      expect(user.authorized?).to eq(false)
    end

    it 'returns false for inactive users' do
      user = User.take
      expect(user.authorized?).to eq(true) # just to be sure

      user.user_active = false
      expect(user.authorized?).to eq(false)
    end
  end
end
