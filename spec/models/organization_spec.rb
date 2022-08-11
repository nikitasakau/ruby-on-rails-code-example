RSpec.describe Organization do
  subject { create(:organization) }

  context 'for validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'for associations' do
    it { is_expected.to have_many(:memberships) }
  end
end
