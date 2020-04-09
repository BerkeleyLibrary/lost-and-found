class RecordPolicy < ApplicationPolicy
  def update?
    user.role?(:admin) || user.role?(:dev)
  end
end
