RSpec.describe Tree::Template::Instances::Sync do
  subject(:call) { described_class.call(tree_template: tree_template) }

  let!(:tree_template) { create(:tree_template) }

  let!(:tree_instance_1) { create(:tree_instance, template: tree_template) }
  let!(:tree_instance_2) { create(:tree_instance, template: tree_template) }
  let!(:tree_instance_3) { create(:tree_instance, template: tree_template) }

  before do
    allow(Tree::Instance::Sync).to receive(:call).with(tree_instance: tree_instance_1)
    allow(Tree::Instance::Sync).to receive(:call).with(tree_instance: tree_instance_2)
    allow(Tree::Instance::Sync).to receive(:call).with(tree_instance: tree_instance_3)
  end

  describe '#call' do
    it 'calls the Tree::Instance::Sync service for the first tree instance' do
      call

      expect(Tree::Instance::Sync).to have_received(:call).with(tree_instance: tree_instance_1)
    end

    it 'calls the Tree::Instance::Sync service for the second tree instance' do
      call

      expect(Tree::Instance::Sync).to have_received(:call).with(tree_instance: tree_instance_2)
    end

    it 'calls the Tree::Instance::Sync service for the third tree instance' do
      call

      expect(Tree::Instance::Sync).to have_received(:call).with(tree_instance: tree_instance_3)
    end

    it 'calls the Tree::Instance::Sync service the correct number of times' do
      call

      expect(Tree::Instance::Sync).to have_received(:call).exactly(tree_template.instances.count).times
    end
  end
end
