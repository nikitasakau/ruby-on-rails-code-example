RSpec.describe Tree::Instance::Node::Completion::Create do
  subject(:call) { described_class.call(tree_instance_node: tree_instance_node) }

  shared_examples "does not set node's completed_at" do
    it "does not set node's completed_at" do
      call

      expect(tree_instance_node_1.reload.completed_at).to eq nil
    end
  end

  shared_examples "does not unblock node's children" do
    it "does not unblock node's children" do
      call

      expect(
        tree_instance.reload.nodes
          .where(id: [tree_instance_node_2.id, tree_instance_node_3.id]).pluck(:unblocked_at),
      ).to eq [nil, nil]
    end
  end

  shared_examples 'does not unblock other nodes' do
    it 'does not unblock other nodes' do
      call

      expect(
        tree_instance.reload.nodes
          .where(id: [tree_instance_node_4.id, tree_instance_node_5.id]).pluck(:unblocked_at),
      ).to eq [nil, nil]
    end
  end

  shared_examples 'returns failed Tree::Instance::Node::Completion::Create::Result' do
    it 'returns failed Tree::Instance::Node::Completion::Create::Result' do
      expect(call).to eq Tree::Instance::Node::Completion::Create::Result.new(false)
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
    )
  end

  let!(:tree_instance_node_2) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_1,
      template_node: tree_template_node_2,
    )
  end

  let!(:tree_instance_node_3) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_1,
      template_node: tree_template_node_3,
    )
  end

  let!(:tree_instance_node_4) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_3,
      template_node: tree_template_node_4,
    )
  end

  let!(:tree_instance_node_5) do
    create(
      :tree_instance_node,
      instance: tree_instance,
      parent: tree_instance_node_2,
      template_node: tree_template_node_5,
    )
  end

  let(:tree_instance_node) { tree_instance_node_1 }

  it "updates node's completed_at to Time.now.utc" do
    call

    expect(tree_instance_node_1.reload.completed_at).to be_within(1.minute).of Time.now.utc
  end

  it "unblocks node's children" do
    call

    expect(
      tree_instance.reload.nodes
        .where(id: [tree_instance_node_2.id, tree_instance_node_3.id]).pluck(:unblocked_at),
    ).to all(be_within(1.minute).of(Time.now.utc))
  end

  it 'does not unblock other nodes' do
    call

    expect(
      tree_instance.reload.nodes
        .where(id: [tree_instance_node_4.id, tree_instance_node_5.id]).pluck(:unblocked_at),
    ).to eq [nil, nil]
  end

  it 'returns successful Result' do
    expect(call).to eq Tree::Instance::Node::Completion::Create::Result.new(true)
  end

  context 'when tree_instance_node is nil' do
    let(:tree_instance_node) { nil }

    include_examples "does not set node's completed_at"
    include_examples "does not unblock node's children"
    include_examples 'does not unblock other nodes'
    include_examples 'returns failed Tree::Instance::Node::Completion::Create::Result'
  end

  context 'when the node is blocked' do
    before do
      tree_instance_node.update(unblocked_at: nil)
    end

    include_examples "does not set node's completed_at"
    include_examples "does not unblock node's children"
    include_examples 'does not unblock other nodes'
    include_examples 'returns failed Tree::Instance::Node::Completion::Create::Result'
  end

  context 'when the node is already completed' do
    let(:tree_instance_node_1_completed_at_before) { tree_instance_node_1.completed_at }

    before do
      tree_instance_node.update(completed_at: Time.now.utc)
      tree_instance_node_1_completed_at_before
    end

    it "does not update node's completed_at" do
      call

      expect(tree_instance_node_1.reload.completed_at).to eq tree_instance_node_1_completed_at_before
    end

    include_examples "does not unblock node's children"
    include_examples 'does not unblock other nodes'
    include_examples 'returns failed Tree::Instance::Node::Completion::Create::Result'
  end

  context 'when failed to update the node' do
    before do
      allow(tree_instance_node).to receive(:update).and_return(false)
    end

    include_examples "does not set node's completed_at"
    include_examples "does not unblock node's children"
    include_examples 'does not unblock other nodes'
    include_examples 'returns failed Tree::Instance::Node::Completion::Create::Result'
  end

  context 'when the node is not a root node' do
    let(:tree_instance_node) { tree_instance_node_3 }

    before do
      tree_instance_node_1.update(completed_at: Time.now.utc)
      tree_instance_node_2.update(unblocked_at: Time.now.utc)
      tree_instance_node_3.update(unblocked_at: Time.now.utc)
    end

    it "updates node's completed_at to Time.now.utc" do
      call

      expect(tree_instance_node_3.reload.completed_at).to be_within(1.minute).of Time.now.utc
    end

    it "unblocks node's children" do
      call

      expect(
        tree_instance.reload.nodes
          .where(id: [tree_instance_node_4.id]).pluck(:unblocked_at),
      ).to all(be_within(1.minute).of(Time.now.utc))
    end

    it 'does not unblock the nodes where it is not required' do
      call

      expect(
        tree_instance.reload.nodes
          .where(id: [tree_instance_node_5.id]).pluck(:unblocked_at),
      ).to eq [nil]
    end

    it 'returns successful Result' do
      expect(call).to eq Tree::Instance::Node::Completion::Create::Result.new(true)
    end
  end
end
