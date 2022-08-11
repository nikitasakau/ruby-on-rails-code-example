RSpec.describe Tree::Instance::NodePolicy do
  subject(:policy) { described_class.new(current_user, tree_instance_node) }

  describe '#create?' do
    let(:current_user) { create(:user) }

    let(:tree_instance_node) { create(:tree_instance_node) }
    let(:tree_instance_policy) { instance_double(Tree::InstancePolicy, update?: can_update_tree_instance?) }
    let(:can_update_tree_instance?) { true }

    before do
      allow(Tree::InstancePolicy).to receive(:new)
        .with(current_user, tree_instance_node.instance).and_return(tree_instance_policy)
    end

    it 'returns true' do
      expect(policy.create?).to eq true
    end

    context 'when it is not allowed to update the instance for user' do
      let(:can_update_tree_instance?) { false }

      it 'returns false' do
        expect(policy.create?).to eq false
      end
    end

    context 'when tree_instance is blank' do
      let(:tree_instance_node) { build(:tree_instance_node) }

      before do
        tree_instance_node.update(instance: nil)
      end

      it 'returns false' do
        expect(policy.create?).to eq false
      end
    end
  end

  describe '#update?' do
    let(:current_user) { create(:user) }

    let(:tree_instance_node) { create(:tree_instance_node) }
    let(:tree_instance_policy) { instance_double(Tree::InstancePolicy, update?: can_update_tree_instance?) }
    let(:can_update_tree_instance?) { true }

    before do
      allow(Tree::InstancePolicy).to receive(:new)
        .with(current_user, tree_instance_node.instance).and_return(tree_instance_policy)
    end

    it 'returns true' do
      expect(policy.update?).to eq true
    end

    context 'when it is not allowed to update the instance for user' do
      let(:can_update_tree_instance?) { false }

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end

    context 'when tree_instance is blank' do
      before do
        tree_instance_node.update(instance: nil)
      end

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end
  end
end
