RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(current_user, record) }

  let(:record) { create(:user) }

  describe '#show?' do
    context 'when user tries to get their own params' do
      let(:current_user) { record }

      it 'returns true' do
        expect(policy.show?).to eq true
      end
    end

    context 'when user tries to get not their own params' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.show?).to eq false
      end
    end
  end

  describe '#update?' do
    context 'when user tries to update their own params' do
      let(:current_user) { record }

      it 'returns true' do
        expect(policy.update?).to eq true
      end
    end

    context 'when user tries to update not their own params' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end
  end
end
