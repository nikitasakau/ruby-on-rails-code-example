# frozen_string_literal: true

RSpec.describe Tree::Template::Instances::SyncJob do
  describe '#perform_now' do
    subject(:perform_now) { described_class.perform_now(tree_template_id: tree_template.id) }

    let(:tree_template) { create(:tree_template) }

    before do
      allow(Tree::Template::Instances::Sync).to receive(:call).with(tree_template: tree_template)
    end

    it 'calls the Tree::Template::Instances::Sync service with correct params' do
      perform_now

      expect(Tree::Template::Instances::Sync).to have_received(:call).with(tree_template: tree_template)
    end
  end
end
