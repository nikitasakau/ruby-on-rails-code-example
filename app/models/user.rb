class User < ApplicationRecord
  include Verifiable
  include Tree::Template::Ownerable

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :password_digest, presence: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  has_secure_password

  has_many :auth_sessions, dependent: :destroy, class_name: 'Auth::Session'
  has_one :profile, required: true, dependent: :destroy

  has_many :tree_instances, dependent: :destroy, class_name: 'Tree::Instance'

  has_many :organization_memberships, dependent: :destroy, class_name: 'Organization::Membership'
  has_many :organizations, through: :organization_memberships

  delegate :full_name, to: :profile
end
