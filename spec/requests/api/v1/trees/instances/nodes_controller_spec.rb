RSpec.describe Api::V1::Trees::Instances::NodesController do
  describe 'GET api/v1/trees/instances/:instance_id/nodes' do
    subject(:do_request) { get "/api/v1/trees/instances/#{tree_instance_id}/nodes" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_instance_id) { tree_instance.id }
    let(:tree_instance) { create(:tree_instance) }

    let(:tree_instance_nodes_serialized_json) do
      [
        {
          object: {
            id: Faker::Number.unique.number.to_s,
            type: 'treeInstanceNode',
            attributes: {},
          },
          children: [
            {
              object: {
                id: Faker::Number.unique.number.to_s,
                type: 'treeInstanceNode',
                attributes: {},
              },
              children: [],
            },
          ],
        },
      ]
    end

    let(:expected_tree_instance_nodes_json) do
      {
        data: tree_instance_nodes_serialized_json,
      }
    end

    before do
      allow(Tree::Instance::Nodes::Serialize).to receive(:call)
        .with(tree_instance: tree_instance, current_user: current_user)
        .and_return(tree_instance_nodes_serialized_json)
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_ok
    end

    it 'returns JSON with correct data' do
      do_request

      expect(JSON.parse(response.body).to_h.deep_symbolize_keys).to eq expected_tree_instance_nodes_json
    end

    context 'when tree instance does not exist' do
      before do
        tree_instance.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end
end
