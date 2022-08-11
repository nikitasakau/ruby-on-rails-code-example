class Tree::Instance < ApplicationRecord
  include Tree::Entity::Nodable

  validates :user, presence: true
  validates :template, presence: true
  validates :tree_template_id, uniqueness: { scope: :user_id }

  belongs_to :user
  belongs_to :template,
    foreign_key: 'tree_template_id',
    class_name: 'Tree::Template',
    inverse_of: :instances

  has_many :nodes,
    foreign_key: 'tree_instance_id',
    inverse_of: :instance,
    dependent: :destroy
end
