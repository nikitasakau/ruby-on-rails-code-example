RSpec.describe Tree::Template do
  subject(:tree_template) { create(:tree_template) }

  context 'for Tree::Entity::Node::Parentable' do
    let(:entity) { tree_template }

    let!(:root_tree_template_node) { create(:tree_template_node, template: entity) }

    before do
      create(:tree_template_node, template: entity, parent: root_tree_template_node)
    end

    it_behaves_like 'Tree::Entity::Nodable'
  end

  context 'for validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:owner) }
  end

  context 'for associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to have_many(:nodes) }
    it { is_expected.to have_many(:instances) }
  end
end
