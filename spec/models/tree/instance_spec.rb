RSpec.describe Tree::Instance do
  subject { create(:tree_instance) }

  context 'for Tree::Entity::Node::Parentable' do
    let(:entity) { create(:tree_instance) }

    let!(:root_tree_instance_node) { create(:tree_instance_node, instance: entity) }

    before do
      create(:tree_instance_node, instance: entity, parent: root_tree_instance_node)
    end

    it_behaves_like 'Tree::Entity::Nodable'
  end

  context 'for validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:template) }
    it { is_expected.to validate_uniqueness_of(:tree_template_id).scoped_to(:user_id) }
  end

  context 'for associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:template) }
    it { is_expected.to have_many(:nodes) }
  end
end
