RSpec.describe Tree::Instance::Sync do
  subject(:call) { described_class.call(tree_instance: tree_instance) }

  let(:tree_instance) { create(:tree_instance) }

  before do
    allow(Tree::Instance::Sync::CreateMissingNodes).to receive(:call)
  end

  it 'calls the Tree::Instance::Sync::CreateMissingNodes with correct params' do
    call

    expect(Tree::Instance::Sync::CreateMissingNodes).to have_received(:call).with(tree_instance: tree_instance)
  end
end
