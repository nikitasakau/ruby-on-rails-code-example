class User::Create
  include Callable

  Result = Struct.new(:successful?, :user)

  def initialize(email:, password:, first_name:, last_name:)
    @email = email
    @password = password
    @first_name = first_name
    @last_name = last_name
  end

  def call
    user.build_profile(first_name: first_name, last_name: last_name).save!

    Result.new(true, user)
  rescue StandardError
    Result.new(false)
  end

  private

  attr_reader :email, :password, :first_name, :last_name

  def user
    @_user ||= User.new(email: email, password: password)
  end
end
