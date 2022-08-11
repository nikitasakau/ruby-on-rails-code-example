RSpec.describe Tree::InstancePolicy do
  subject(:policy) { described_class.new(current_user, record) }

  describe '#update?' do
    let(:user) { create(:user) }

    let(:record) { create(:tree_instance, user: user) }

    context 'when user tries to update their own tree instance' do
      let(:current_user) { user }

      it 'returns true' do
        expect(policy.update?).to eq true
      end
    end

    context 'when user tries to update not their own tree instance' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end
  end

  describe '#destroy?' do
    let(:user) { create(:user) }

    let(:record) { create(:tree_instance, user: user) }

    context 'when user tries to destroy their own tree instance' do
      let(:current_user) { user }

      it 'returns true' do
        expect(policy.destroy?).to eq true
      end
    end

    context 'when user tries to destroy not their own tree instance' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.destroy?).to eq false
      end
    end
  end
end
