class RecordPolicy < ApplicationPolicy
  def update?
    user.role?(:admin) || user.role?(:dev) | user.role?(:student)
  end
end
