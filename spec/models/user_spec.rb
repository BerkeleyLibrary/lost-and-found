require 'calnet_helper'

describe User, type: :model do
  it 'user should have role' do
    user = User.new()
    assert_nil(user.role)
    user.role=Role.new(name: 'admin')
    assert(user.role)
  end
end
