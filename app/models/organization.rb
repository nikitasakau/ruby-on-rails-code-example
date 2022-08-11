class Organization < ApplicationRecord
  validates :name, presence: true

  has_many :memberships, dependent: :destroy
end
