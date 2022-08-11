RSpec.describe Tree::Instance::Node::Completion::Destroy do
  subject(:call) { described_class.call(tree_instance_node: tree_instance_node) }

  shared_examples "does not set node's completed_at to nil" do
    it "does not set node's completed_at to nil" do
      call

      expect(tree_instance_node_1.reload.completed_at).not_to be_nil
    end
  end

  shared_examples "does not block node's descendants" do
    it "does not block node's descendants" do
      call

      expect(
        tree_instance.reload.nodes
        .where(id: [tree_instance_node_2.id,
          tree_instance_node_3.id,
          tree_instance_node_4.id,
          tree_instance_node_5.id]).pluck(:unblocked_at).compact.size,
      ).to eq 4
    end
  end

  shared_examples 'does not mark all descendants as incomplete' do
    it 'does not mark all descendants as incomplete' do
      call

      expect(
        tree_instance.reload.nodes
        .where(id: [tree_instance_node_2.id,
          tree_instance_node_3.id,
          tree_instance_node_4.id,
          tree_instance_node_5.id]).pluck(:completed_at).compact.size,
      ).to eq 4
    end
  end

  shared_examples 'returns failed Tree::Instance::Node::Completion::Destroy::Result' do
    it 'returns failed Tree::Instance::Node::Completion::Destroy::Result' do
      expect(call).to eq Tree::Instance::Node::Completion::Destroy::Result.new(false)
    end
  end

  let(:tree_template) { create(:tree_template) }

  let(:tree_template_node_1) { create(:tree_template_node, template: tree_template) }

  let(:tree_template_node_2) do
    create(:tree_template_node, template: tree_template, parent: tree_template_node_1)
  end

  let(:tree_template_node_3) do
    create(:tree_template_node, template: tree_template, parent: tree_template_node_1)
  end

  let(:tree_template_node_4) do
    create(:tree_template_node, template: tree_template, parent: tree_template_node_3)
  end

  let(:tree_template_node_5) do
    create(:tree_template_node, template: tree_template, parent: tree_template_node_3)
  end

  let(:tree_instance) { create(:tree_instance, template: tree_template) }

  let!(:tree_instance_node_1) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      template_node: tree_template_node_1,
      unblocked_at: Time.now.utc,
      completed_at: Time.now.utc,
    )
  end

  let!(:tree_instance_node_2) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_1,
      template_node: tree_template_node_2,
      unblocked_at: Time.now.utc,
      completed_at: Time.now.utc,
    )
  end

  let!(:tree_instance_node_3) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_1,
      template_node: tree_template_node_3,
      unblocked_at: Time.now.utc,
      completed_at: Time.now.utc,
    )
  end

  let!(:tree_instance_node_4) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_3,
      template_node: tree_template_node_4,
      unblocked_at: Time.now.utc,
      completed_at: Time.now.utc,
    )
  end

  let!(:tree_instance_node_5) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_2,
      template_node: tree_template_node_5,
      unblocked_at: Time.now.utc,
      completed_at: Time.now.utc,
    )
  end

  let(:tree_instance_node) { tree_instance_node_1 }

  it "updates node's completed_at to nil" do
    call

    expect(tree_instance_node_1.reload.completed_at).to eq nil
  end

  it "blocks node's descendants" do
    call

    expect(
      tree_instance.reload.nodes
      .where(id: [tree_instance_node_2.id,
        tree_instance_node_3.id,
        tree_instance_node_4.id,
        tree_instance_node_5.id]).pluck(:unblocked_at),
    ).to eq [nil, nil, nil, nil]
  end

  it 'marks all descendants as incomplete' do
    call

    expect(
      tree_instance.reload.nodes
      .where(id: [tree_instance_node_2.id,
        tree_instance_node_3.id,
        tree_instance_node_4.id,
        tree_instance_node_5.id]).pluck(:completed_at),
    ).to eq [nil, nil, nil, nil]
  end

  it 'returns successful Result' do
    expect(call).to eq Tree::Instance::Node::Completion::Destroy::Result.new(true)
  end

  context 'when tree_instance_node is nil' do
    let(:tree_instance_node) { nil }

    include_examples "does not set node's completed_at to nil"
    include_examples "does not block node's descendants"
    include_examples 'does not mark all descendants as incomplete'
    include_examples 'returns failed Tree::Instance::Node::Completion::Destroy::Result'
  end

  context 'when tree_instance_node is blocked' do
    before do
      tree_instance_node.update(unblocked_at: nil)
    end

    include_examples "does not set node's completed_at to nil"
    include_examples "does not block node's descendants"
    include_examples 'does not mark all descendants as incomplete'
    include_examples 'returns failed Tree::Instance::Node::Completion::Destroy::Result'
  end

  context 'when the node is not completed' do
    before do
      tree_instance_node.update(completed_at: nil)
    end

    it "does not update node's completed_at" do
      call

      expect(tree_instance_node_1.reload.completed_at).to be_nil
    end

    include_examples "does not block node's descendants"
    include_examples 'does not mark all descendants as incomplete'
    include_examples 'returns failed Tree::Instance::Node::Completion::Destroy::Result'
  end

  context 'when failed to update the node' do
    before do
      allow(tree_instance_node).to receive(:update).and_return(false)
    end

    include_examples "does not set node's completed_at to nil"
    include_examples "does not block node's descendants"
    include_examples 'does not mark all descendants as incomplete'
    include_examples 'returns failed Tree::Instance::Node::Completion::Destroy::Result'
  end

  context 'when the node is not a root node' do
    let(:tree_instance_node) { tree_instance_node_3 }

    it "updates node's completed_at to nil" do
      call

      expect(tree_instance_node_3.reload.completed_at).to eq nil
    end

    it "blocks node's descendants" do
      call

      expect(
        tree_instance.reload.nodes
        .where(id: [tree_instance_node_4.id]).pluck(:unblocked_at),
      ).to eq [nil]
    end

    it 'marks all descendants as incomplete' do
      call

      expect(
        tree_instance.reload.nodes
        .where(id: [tree_instance_node_4.id]).pluck(:completed_at),
      ).to eq [nil]
    end

    it 'does not block the nodes where it is not required' do
      call

      expect(
        tree_instance.reload.nodes
        .where(id: [tree_instance_node_1.id,
          tree_instance_node_2.id,
          tree_instance_node_3.id,
          tree_instance_node_5.id]).pluck(:unblocked_at).compact.size,
      ).to eq 4
    end

    it 'does not mark the nodes as incomplete where it is not required' do
      call

      expect(
        tree_instance.reload.nodes
        .where(id: [tree_instance_node_1.id,
          tree_instance_node_2.id,
          tree_instance_node_5.id]).pluck(:completed_at).compact.size,
      ).to eq 3
    end

    it 'returns successful Result' do
      expect(call).to eq Tree::Instance::Node::Completion::Destroy::Result.new(true)
    end
  end
end
