class Tree::TemplatePolicy < ApplicationPolicy
  def create?
    user == record.owner
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
