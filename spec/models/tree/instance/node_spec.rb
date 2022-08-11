RSpec.describe Tree::Instance::Node do
  subject { create(:tree_instance_node) }

  context 'for Tree::Entity::Node::Parentable' do
    let(:tree_entity_node_name) { :tree_instance_node }
    let(:tree_entity_node_entity_association_name) { :instance }
    let(:tree_entity_name) { :tree_instance }

    it_behaves_like 'Tree::Entity::Node::Parentable'
  end

  context 'for validations' do
    it { is_expected.to validate_uniqueness_of(:tree_template_node_id).scoped_to(:tree_instance_id) }
    it { is_expected.to validate_presence_of(:template_node) }
    it { is_expected.to validate_presence_of(:instance) }

    context 'for template_node_is_valid' do
      subject { build(:tree_instance_node, instance: instance, template_node: template_node) }

      let(:instance) { create(:tree_instance) }
      let(:template_node) { create(:tree_template_node, template: template) }

      context 'when the template_node has the same template as the instance' do
        let(:template) { instance.template }

        it { is_expected.to be_valid }
      end

      context 'when the template_node has not the same template as the instance' do
        let(:template) { create(:tree_template) }

        it { is_expected.not_to be_valid }
      end
    end
  end

  context 'for associations' do
    it { is_expected.to belong_to(:instance) }
    it { is_expected.to belong_to(:template_node) }
  end

  describe '#completed?' do
    subject(:tree_instance_node) { create(:tree_instance_node, completed_at: completed_at) }

    let(:completed_at) { Time.now.utc }

    it 'returns true' do
      expect(tree_instance_node).to be_completed
    end

    context 'when completed_at is nil' do
      let(:completed_at) { nil }

      it 'returns false' do
        expect(tree_instance_node).not_to be_completed
      end
    end
  end

  describe '#blocked?' do
    subject(:tree_instance_node) { create(:tree_instance_node, unblocked_at: unblocked_at) }

    let(:unblocked_at) { Time.now.utc }

    it 'returns false' do
      expect(tree_instance_node).not_to be_blocked
    end

    context 'when unblocked_at is nil' do
      let(:unblocked_at) { nil }

      it 'returns true' do
        expect(tree_instance_node).to be_blocked
      end
    end
  end
end
