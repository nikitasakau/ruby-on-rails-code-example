RSpec.describe Tree::Template::NodePolicy do
  subject(:policy) { described_class.new(current_user, tree_template_node) }

  describe '#create?' do
    let(:current_user) { create(:user) }

    let(:tree_template_node) { create(:tree_template_node) }
    let(:tree_template_policy) { instance_double(Tree::TemplatePolicy, update?: can_update_tree_template?) }
    let(:can_update_tree_template?) { true }

    before do
      allow(Tree::TemplatePolicy).to receive(:new)
        .with(current_user, tree_template_node.template).and_return(tree_template_policy)
    end

    it 'returns true' do
      expect(policy.create?).to eq true
    end

    context 'when it is not allowed to update the template for user' do
      let(:can_update_tree_template?) { false }

      it 'returns false' do
        expect(policy.create?).to eq false
      end
    end

    context 'when tree_template is blank' do
      before do
        tree_template_node.update(template: nil)
      end

      it 'returns false' do
        expect(policy.create?).to eq false
      end
    end
  end

  describe '#update?' do
    let(:current_user) { create(:user) }

    let(:tree_template_node) { create(:tree_template_node) }
    let(:tree_template_policy) { instance_double(Tree::TemplatePolicy, update?: can_update_tree_template?) }
    let(:can_update_tree_template?) { true }

    before do
      allow(Tree::TemplatePolicy).to receive(:new)
        .with(current_user, tree_template_node.template).and_return(tree_template_policy)
    end

    it 'returns true' do
      expect(policy.update?).to eq true
    end

    context 'when it is not allowed to update the template for user' do
      let(:can_update_tree_template?) { false }

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end

    context 'when tree_template is blank' do
      before do
        tree_template_node.update(template: nil)
      end

      it 'returns false' do
        expect(policy.update?).to eq false
      end
    end
  end

  describe '#destroy?' do
    let(:current_user) { create(:user) }

    let(:tree_template_node) { create(:tree_template_node) }
    let(:tree_template_policy) { instance_double(Tree::TemplatePolicy, update?: can_update_tree_template?) }
    let(:can_update_tree_template?) { true }

    before do
      allow(Tree::TemplatePolicy).to receive(:new)
        .with(current_user, tree_template_node.template).and_return(tree_template_policy)
    end

    it 'returns true' do
      expect(policy.destroy?).to eq true
    end

    context 'when it is not allowed to update the template for user' do
      let(:can_update_tree_template?) { false }

      it 'returns false' do
        expect(policy.destroy?).to eq false
      end
    end

    context 'when tree_template is blank' do
      before do
        tree_template_node.update(template: nil)
      end

      it 'returns false' do
        expect(policy.destroy?).to eq false
      end
    end
  end
end
