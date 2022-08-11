RSpec.describe Api::V1::Trees::Templates::NodesController do
  describe 'GET api/v1/trees/templates/:template_id/nodes' do
    subject(:do_request) { get "/api/v1/trees/templates/#{tree_template_id}/nodes" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template_id) { tree_template.id }
    let(:tree_template) { create(:tree_template) }

    let(:tree_template_nodes_serialized_json) do
      [
        {
          object: {
            id: Faker::Number.unique.number.to_s,
            type: 'treeTemplateNode',
            attributes: {},
          },
          children: [
            {
              object: {
                id: Faker::Number.unique.number.to_s,
                type: 'treeTemplateNode',
                attributes: {},
              },
              children: [],
            },
          ],
        },
      ]
    end

    let(:expected_tree_template_nodes_json) do
      {
        data: tree_template_nodes_serialized_json,
      }
    end

    before do
      allow(Tree::Template::Nodes::Serialize).to receive(:call)
        .with(tree_template: tree_template, current_user: current_user)
        .and_return(tree_template_nodes_serialized_json)
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_ok
    end

    it 'returns JSON with correct data' do
      do_request

      expect(JSON.parse(response.body).to_h.deep_symbolize_keys).to eq expected_tree_template_nodes_json
    end

    context 'when tree template does not exist' do
      before do
        tree_template.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'POST api/v1/trees/templates/nodes' do
    subject(:do_request) { post '/api/v1/trees/templates/nodes', params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:icon) { Faker::Lorem.multibyte }
    let(:title) { Faker::Lorem.sentence }
    let(:description) { Faker::Lorem.sentence }
    let(:tree_template) { create(:tree_template) }
    let(:parent_tree_template_node_id) { nil }

    let(:params) do
      {
        tree_template_node: {
          icon: icon,
          title: title,
          description: description,
          tree_template_id: tree_template.id,
          parent_tree_template_node_id: parent_tree_template_node_id,
        },
      }
    end

    let(:tree_template_node_policy) do
      instance_double(
        Tree::Template::NodePolicy,
        create?: current_user_has_permissions?,
        update?: true,
        destroy?: true,
      )
    end

    before do
      allow(Tree::Template::NodePolicy).to receive(:new).and_return(tree_template_node_policy)
    end

    context 'when current user has permissions' do
      let(:current_user_has_permissions?) { true }

      context 'when the tree template node has been saved successfully' do
        let(:expected_tree_template_node_json) do
          Tree::Template::NodeSerializer.new(
            Tree::Template::Node.last,
            {
              params: {
                current_user: current_user,
              },
            },
          ).to_json
        end

        it 'returns 201 HTTP status code' do
          do_request

          expect(response).to be_created
        end

        it 'returns JSON with correct data' do
          do_request

          expect(response.body).to eq expected_tree_template_node_json
        end

        it 'creates new Tree::Template::Node for tree template' do
          do_request

          expect(tree_template.nodes.last).to have_attributes(title: title, description: description)
        end

        it 'enqueues the Tree::Template::Instances::Sync with correct params' do
          expect { do_request }.to have_enqueued_job(Tree::Template::Instances::SyncJob).with(
            tree_template_id: tree_template.id,
          ).on_queue('synchronizations').exactly(:once)
        end
      end

      context 'when the tree template node cannot be saved successfully' do
        let(:title) { nil }

        it_behaves_like 'when the entity is unprocessable'
      end
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end
  end

  describe 'PATCH/PUT api/v1/trees/templates/nodes/:id' do
    subject(:do_request) { put "/api/v1/trees/templates/nodes/#{tree_template_node.id}", params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template_node) { create(:tree_template_node, template: tree_template) }
    let(:tree_template) { create(:tree_template) }

    let(:new_icon) { Faker::Lorem.multibyte }
    let(:new_title) { Faker::Lorem.sentence }
    let(:new_description) { Faker::Lorem.sentence }

    let(:params) do
      {
        tree_template_node: {
          icon: new_icon,
          title: new_title,
          description: new_description,
          treeTemplateId: Faker::Number.between(from: 1, to: 10).to_s,
        },
      }
    end

    let(:tree_template_node_policy) do
      instance_double(
        Tree::Template::NodePolicy,
        update?: current_user_has_permissions?,
        destroy?: true,
      )
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(Tree::Template::NodePolicy).to receive(:new)
        .with(current_user, tree_template_node)
        .and_return(tree_template_node_policy)
    end

    context 'when the tree template node has been updated successfully' do
      let(:expected_tree_template_node_json) do
        Tree::Template::NodeSerializer.new(
          tree_template_node.reload,
          {
            params: {
              current_user: current_user,
            },
          },
        ).to_json
      end

      it 'returns 200 HTTP status code' do
        do_request

        expect(response).to be_ok
      end

      it 'returns JSON with correct data' do
        do_request

        expect(response.body).to eq expected_tree_template_node_json
      end

      it 'updates the Tree::Template::Node with allowable passed params only' do
        do_request

        expect(tree_template_node.reload).to have_attributes(
          icon: new_icon,
          title: new_title,
          description: new_description,
          tree_template_id: tree_template.id,
        )
      end
    end

    context 'when the tree template cannot be updated successfully' do
      let(:new_title) { nil }

      it_behaves_like 'when the entity is unprocessable'
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when tree template node does not exist' do
      before do
        tree_template_node.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'DELETE api/v1/trees/templates/nodes/:id' do
    subject(:do_request) { delete "/api/v1/trees/templates/nodes/#{tree_template_node.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template_node) { create(:tree_template_node) }

    let(:tree_template_node_policy) do
      instance_double(Tree::Template::NodePolicy, destroy?: current_user_has_permissions?)
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(Tree::Template::NodePolicy).to receive(:new)
        .with(current_user, tree_template_node)
        .and_return(tree_template_node_policy)
    end

    context 'when the tree template node has been destroyed successfully' do
      it 'returns 204 HTTP status code' do
        do_request

        expect(response).to be_no_content
      end

      it 'destroys the tree template node' do
        do_request

        expect { tree_template_node.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the tree template node cannot be destroyed successfully' do
      before do
        allow(Tree::Template::Node).to receive(:find).and_return(tree_template_node)
        allow(tree_template_node).to receive(:destroy).and_return(false)
      end

      it_behaves_like 'when a bad request'
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when tree template node does not exist' do
      before do
        tree_template_node.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end
end
