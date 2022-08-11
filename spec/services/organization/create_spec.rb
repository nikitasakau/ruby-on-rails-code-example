RSpec.describe Organization::Create do
  subject(:call) do
    described_class.call(
      name: name,
      description: description,
      creator: creator,
    )
  end

  shared_examples 'when provided params are correct' do
    it 'creates a correct organization' do
      call

      expect(Organization.last).to have_attributes(name: name, description: description)
    end

    it 'creates an admin' do
      freeze_time do
        call

        expect(Organization::Membership.last).to have_attributes(
          user_id: creator.id,
          admin: true,
          organization_id: Organization.last.id,
          inviter_id: creator.id,
          confirmed_at: Time.now.utc,
        )
      end
    end

    it 'returns a successful result' do
      expect(call).to eq Organization::Create::Result.new(true, Organization.last)
    end
  end

  shared_examples 'when provided params are not correct' do
    it 'does not create a new organization' do
      call

      expect { call }.not_to change { Organization.count }
    end

    it 'does not create a new organization membership' do
      call

      expect { call }.not_to change { Organization::Membership.count }
    end

    it 'returns a failed result' do
      expect(call).to eq Organization::Create::Result.new(false)
    end
  end

  let(:name) { Faker::Lorem.word }
  let(:description) { Faker::Lorem.paragraph }
  let(:creator) { create(:user) }

  include_examples 'when provided params are correct'

  context 'when the name is nil' do
    let(:name) { nil }

    include_examples 'when provided params are not correct'
  end

  context 'when the description is nil' do
    let(:description) { nil }

    include_examples 'when provided params are correct'
  end

  context 'when the creator is nil' do
    let(:creator) { nil }

    include_examples 'when provided params are not correct'
  end
end
