RSpec.describe Organization::Membership do
  subject { create(:organization_membership) }

  context 'for validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:inviter) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:organization_id) }
  end

  context 'for associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:inviter) }
  end
end
