RSpec.describe Tree::Template::Node do
  subject { create(:tree_template_node) }

  context 'for Tree::Entity::Node::Parentable' do
    let(:tree_entity_node_name) { :tree_template_node }
    let(:tree_entity_node_entity_association_name) { :template }
    let(:tree_entity_name) { :tree_template }

    it_behaves_like 'Tree::Entity::Node::Parentable'
  end

  context 'for validations' do
    it { is_expected.to validate_presence_of(:icon) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:template) }
  end

  context 'for associations' do
    it { is_expected.to belong_to(:template) }
    it { is_expected.to have_many(:instance_nodes) }
  end
end
