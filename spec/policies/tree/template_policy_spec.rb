RSpec.describe Tree::TemplatePolicy do
  subject(:policy) { described_class.new(current_user, record) }

  describe '#create?' do
    let(:owner) { create(:user) }

    let(:record) { create(:tree_template, owner: owner) }

    context 'when user tries to add tree templates to themselves' do
      let(:current_user) { owner }

      it 'returns true' do
        expect(policy.create?).to eq true
      end
    end

    context 'when random user tries to add tree templates to another user' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.create?).to eq false
      end
    end
  end

  describe '#update?' do
    let(:owner) { create(:user) }

    let(:record) { create(:tree_template, owner: owner) }

    context 'when user tries to update their own tree template' do
      let(:current_user) { owner }

      it 'returns true' do
        expect(policy.update?).to eq true
      end
    end

    context 'when user tries to update not their own tree template' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end
  end

  describe '#destroy?' do
    let(:owner) { create(:user) }

    let(:record) { create(:tree_template, owner: owner) }

    context 'when user tries to destroy their own tree template' do
      let(:current_user) { owner }

      it 'returns true' do
        expect(policy.destroy?).to eq true
      end
    end

    context 'when user tries to destroy not their own tree template' do
      let(:current_user) { create(:user) }

      it 'returns false' do
        expect(policy.destroy?).to eq false
      end
    end
  end
end
