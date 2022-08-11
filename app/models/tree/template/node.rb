class Tree::Template::Node < ApplicationRecord
  include Tree::Entity::Node::Parentable

  validates :icon, presence: true
  validates :title, presence: true
  validates :template, presence: true

  belongs_to :template,
    foreign_key: 'tree_template_id',
    class_name: 'Tree::Template',
    inverse_of: :nodes

  has_many :instance_nodes,
    foreign_key: 'tree_template_node_id',
    class_name: 'Tree::Instance::Node',
    inverse_of: :template_node,
    dependent: :destroy

  alias tree_entity template
end
