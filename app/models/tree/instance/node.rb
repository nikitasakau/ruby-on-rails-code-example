class Tree::Instance::Node < ApplicationRecord
  include Tree::Entity::Node::Parentable

  validates :tree_template_node_id, uniqueness: { scope: :tree_instance_id }
  validates :template_node, presence: true
  validates :instance, presence: true
  validate :template_node_is_valid

  belongs_to :instance,
    foreign_key: 'tree_instance_id',
    class_name: 'Tree::Instance',
    inverse_of: :nodes

  belongs_to :template_node,
    foreign_key: 'tree_template_node_id',
    class_name: 'Tree::Template::Node',
    inverse_of: :instance_nodes

  alias tree_entity instance

  def completed?
    completed_at.present?
  end

  def blocked?
    unblocked_at.blank?
  end

  private

  def template_node_is_valid
    return if (!tree_template_node_id_changed? && persisted?) ||
      template_node.blank? ||
      instance.blank? ||
      template_node.template == instance.template

    errors.add(:template_node, 'is not valid')
  end
end
