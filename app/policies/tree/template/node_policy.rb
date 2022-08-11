class Tree::Template::NodePolicy < ApplicationPolicy
  def create?
    record.template.present? && Tree::TemplatePolicy.new(user, record.template).update?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
