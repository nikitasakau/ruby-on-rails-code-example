RSpec.describe Api::V1::Trees::InstancesController do
  describe 'GET api/v1/trees/instances/:id' do
    subject(:do_request) { get "/api/v1/trees/instances/#{tree_instance.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_instance) { create(:tree_instance) }

    let(:expected_tree_instance_json) do
      Tree::InstanceSerializer.new(tree_instance, { params: { current_user: current_user } }).to_json
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_successful
    end

    it 'returns JSON with correct data' do
      do_request

      expect(response.body).to eq expected_tree_instance_json
    end

    context 'when tree instance does not exist' do
      before do
        tree_instance.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'POST api/v1/trees/instances' do
    subject(:do_request) { post '/api/v1/trees/instances', params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template) { create(:tree_template) }
    let(:params) do
      {
        tree_instance: {
          tree_template_id: tree_template.id,
        },
      }
    end

    before do
      allow(Tree::Instance::Sync).to receive(:call)
    end

    context 'when the tree instance has been saved successfully' do
      let(:expected_tree_instance_json) do
        Tree::InstanceSerializer.new(Tree::Instance.last, { params: { current_user: current_user } }).to_json
      end

      it 'returns 201 HTTP status code' do
        do_request

        expect(response).to be_created
      end

      it 'returns JSON with correct data' do
        do_request

        expect(response.body).to eq expected_tree_instance_json
      end

      it 'creates a new Tree::Instance for the current user' do
        do_request

        expect(current_user.tree_instances.last)
          .to have_attributes(tree_template_id: tree_template.id, user_id: current_user.id)
      end

      it 'calls the Tree::Instance::Sync service with correct params' do
        do_request

        expect(Tree::Instance::Sync).to have_received(:call)
          .with(tree_instance: current_user.tree_instances.last)
      end
    end

    context 'when the current user already has an instance for that template' do
      before do
        create(:tree_instance, user: current_user, template: tree_template)
      end

      it_behaves_like 'when the entity is unprocessable'
    end
  end

  describe 'DELETE api/v1/trees/instances/:id' do
    subject(:do_request) { delete "/api/v1/trees/instances/#{tree_instance.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_instance) { create(:tree_instance) }

    let(:tree_instance_policy) do
      instance_double(Tree::InstancePolicy, destroy?: current_user_has_permissions?)
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(Tree::InstancePolicy).to receive(:new)
        .with(current_user, tree_instance)
        .and_return(tree_instance_policy)
    end

    context 'when the tree instance has been destroyed successfully' do
      it 'returns 204 HTTP status code' do
        do_request

        expect(response).to be_no_content
      end

      it 'destroys the tree instance' do
        do_request

        expect { tree_instance.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the tree instance cannot be destroyed successfully' do
      before do
        allow(Tree::Instance).to receive(:find).and_return(tree_instance)
        allow(tree_instance).to receive(:destroy).and_return(false)
      end

      it_behaves_like 'when a bad request'
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when tree instance does not exist' do
      before do
        tree_instance.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end
end
