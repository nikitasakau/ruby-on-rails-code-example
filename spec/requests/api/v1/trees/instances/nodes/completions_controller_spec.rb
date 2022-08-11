RSpec.describe Api::V1::Trees::Instances::Nodes::CompletionsController do
  describe 'POST api/v1/trees/instances/nodes/:node_id/completion' do
    subject(:do_request) { post "/api/v1/trees/instances/nodes/#{tree_instance_node.id}/completion" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_instance_node) { create(:tree_instance_node) }

    let(:result) { Tree::Instance::Node::Completion::Create::Result.new(successful?) }
    let(:successful?) { true }

    let(:tree_instance_nodes_serialized_json) do
      [
        {
          object: {
            id: tree_instance_node.id.to_s,
            type: 'treeInstanceNode',
            attributes: {},
          },
          children: [],
        },
      ]
    end

    let(:current_user_has_permissions?) { true }
    let(:tree_instance_node_policy) do
      instance_double(Tree::Instance::NodePolicy, update?: current_user_has_permissions?)
    end

    let(:expected_tree_instance_nodes_json) do
      {
        data: tree_instance_nodes_serialized_json,
      }
    end

    before do
      allow(Tree::Instance::Node::Completion::Create).to receive(:call)
        .with(tree_instance_node: tree_instance_node).and_return(result)

      allow(Tree::Instance::Nodes::Serialize).to receive(:call)
        .with(tree_instance: tree_instance_node.instance, current_user: current_user)
        .and_return(tree_instance_nodes_serialized_json)

      allow(Tree::Instance::NodePolicy).to receive(:new)
        .with(current_user, tree_instance_node)
        .and_return(tree_instance_node_policy)
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_ok
    end

    it 'returns JSON with correct data' do
      do_request

      expect(JSON.parse(response.body).to_h.deep_symbolize_keys).to eq expected_tree_instance_nodes_json
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when tree instance node does not exist' do
      before do
        tree_instance_node.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end

    context 'when something went wrong' do
      let(:successful?) { false }

      it_behaves_like 'when the entity is unprocessable'
    end
  end

  describe 'DELETE api/v1/trees/instances/nodes/:node_id/completion' do
    subject(:do_request) { delete "/api/v1/trees/instances/nodes/#{tree_instance_node.id}/completion" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_instance_node) { create(:tree_instance_node) }

    let(:result) { Tree::Instance::Node::Completion::Destroy::Result.new(successful?) }
    let(:successful?) { true }

    let(:tree_instance_nodes_serialized_json) do
      [
        {
          object: {
            id: tree_instance_node.id.to_s,
            type: 'treeInstanceNode',
            attributes: {},
          },
          children: [],
        },
      ]
    end

    let(:current_user_has_permissions?) { true }
    let(:tree_instance_node_policy) do
      instance_double(Tree::Instance::NodePolicy, update?: current_user_has_permissions?)
    end

    let(:expected_tree_instance_nodes_json) do
      {
        data: tree_instance_nodes_serialized_json,
      }
    end

    before do
      allow(Tree::Instance::Node::Completion::Destroy).to receive(:call)
        .with(tree_instance_node: tree_instance_node).and_return(result)

      allow(Tree::Instance::Nodes::Serialize).to receive(:call)
        .with(tree_instance: tree_instance_node.instance, current_user: current_user)
        .and_return(tree_instance_nodes_serialized_json)

      allow(Tree::Instance::NodePolicy).to receive(:new)
        .with(current_user, tree_instance_node)
        .and_return(tree_instance_node_policy)
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_ok
    end

    it 'returns JSON with correct data' do
      do_request

      expect(JSON.parse(response.body).to_h.deep_symbolize_keys).to eq expected_tree_instance_nodes_json
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when tree instance node does not exist' do
      before do
        tree_instance_node.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end

    context 'when something went wrong' do
      let(:successful?) { false }

      it_behaves_like 'when the entity is unprocessable'
    end
  end
end
