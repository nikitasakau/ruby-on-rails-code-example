class Tree::Instance::NodePolicy < ApplicationPolicy
  def create?
    record.instance.present? && Tree::InstancePolicy.new(user, record.instance).update?
  end

  def update?
    create?
  end
end
