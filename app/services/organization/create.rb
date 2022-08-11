class Organization::Create
  include Callable

  Result = Struct.new(:successful?, :organization)

  def initialize(name:, description:, creator:)
    @name = name
    @description = description
    @creator = creator
  end

  def call
    ActiveRecord::Base.transaction do
      @organization = Organization.create!(name: name, description: description)

      create_admin
    end

    Result.new(true, @organization)
  rescue StandardError
    Result.new(false)
  end

  private

  attr_reader :name, :description, :creator

  def create_admin
    Organization::Membership.create!(
      organization: @organization,
      user: creator,
      inviter: creator,
      admin: true,
      confirmed_at: Time.now.utc,
    )
  end
end
