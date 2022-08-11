RSpec.describe User do
  subject { create(:user) }

  it_behaves_like 'Verifiable'
  it_behaves_like 'Tree::Template::Ownerable'

  context 'for validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value('example@email.test').for(:email) }
    it { is_expected.not_to allow_value('example').for(:email) }

    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
  end

  context 'for associations' do
    it { is_expected.to have_many(:auth_sessions) }
    it { is_expected.to have_one(:profile).required }
    it { is_expected.to have_many(:tree_instances) }
    it { is_expected.to have_many(:organization_memberships) }
    it { is_expected.to have_many(:organizations).through(:organization_memberships) }
  end

  it { is_expected.to delegate_method(:full_name).to(:profile) }
end
