class Tree::Template < ApplicationRecord
  include Tree::Entity::Nodable

  validates :title, presence: true
  validates :owner, presence: true

  belongs_to :owner, polymorphic: true

  has_many :nodes,
    foreign_key: 'tree_template_id',
    inverse_of: :template,
    dependent: :destroy

  has_many :instances,
    foreign_key: 'tree_template_id',
    inverse_of: :template,
    dependent: :destroy
end
