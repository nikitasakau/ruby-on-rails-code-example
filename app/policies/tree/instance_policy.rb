class Tree::InstancePolicy < ApplicationPolicy
  def update?
    user == record.user
  end

  def destroy?
    update?
  end
end
