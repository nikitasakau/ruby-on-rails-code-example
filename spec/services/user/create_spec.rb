RSpec.describe User::Create do
  subject(:call) do
    described_class.call(
      email: email,
      password: password,
      first_name: first_name,
      last_name: last_name,
    )
  end

  shared_examples 'when provided params are correct' do
    it 'creates a correct user' do
      call

      expect(User.last).to have_attributes(email: email)
    end

    it 'creates a correct profile' do
      call

      expect(User::Profile.last).to have_attributes(
        first_name: first_name,
        last_name: last_name,
        user_id: User.last.id,
      )
    end

    it 'returns a successful result' do
      expect(call).to eq User::Create::Result.new(true, User.last)
    end
  end

  shared_examples 'when provided params are not correct' do
    it 'does not create a new user' do
      call

      expect { call }.not_to change { User.count }
    end

    it 'does not create a new profile' do
      call

      expect { call }.not_to change { User::Profile.count }
    end

    it 'returns a failed result' do
      expect(call).to eq User::Create::Result.new(false)
    end
  end

  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  include_examples 'when provided params are correct'

  context 'when the email is nil' do
    let(:email) { nil }

    include_examples 'when provided params are not correct'
  end

  context 'when the password is nil' do
    let(:password) { nil }

    include_examples 'when provided params are not correct'
  end

  context 'when the first_name is nil' do
    let(:first_name) { nil }

    include_examples 'when provided params are not correct'
  end

  context 'when the last_name is nil' do
    let(:last_name) { nil }

    include_examples 'when provided params are correct'
  end

  context 'when using not uniq email' do
    before do
      create(:user, email: email)
    end

    include_examples 'when provided params are not correct'
  end

  context 'when the email is invalid' do
    let(:email) { 'invalid_email' }

    include_examples 'when provided params are not correct'
  end
end
