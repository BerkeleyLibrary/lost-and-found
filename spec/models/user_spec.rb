require 'calnet_helper'

describe User, type: :model do
  it 'user should have role' do
    user = User.new()
    assert_nil(user.role)
    user.role=Role.new(role_name: 'admin')
    assert(user.role)
    assert_equal( 'admin' , user.role.role_name)
  end

  it 'New users should default as active' do
    user = User.new()
    assert_equal(true, user.user_active)
  end

  it 'users should accept valid uids' do
    user = User.new()
    user.uid = '12345'
    assert_equal('12345', user.uid, msg = "value should be populated")
  end

end
