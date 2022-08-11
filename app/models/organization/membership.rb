class Organization::Membership < ApplicationRecord
  validates :user, presence: true
  validates :organization, presence: true
  validates :inviter, presence: true

  validates :user_id, uniqueness: { scope: :organization_id }

  belongs_to :user
  belongs_to :organization
  belongs_to :inviter, class_name: 'User'
end
