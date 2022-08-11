RSpec.describe Api::V1::Trees::TemplatesController do
  describe 'GET api/v1/trees/templates/:id' do
    subject(:do_request) { get "/api/v1/trees/templates/#{tree_template.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template) { create(:tree_template) }

    let(:expected_tree_template_json) do
      Tree::TemplateSerializer.new(tree_template, { params: { current_user: current_user } }).to_json
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_successful
    end

    it 'returns JSON with correct data' do
      do_request

      expect(response.body).to eq expected_tree_template_json
    end

    context 'when tree template does not exist' do
      before do
        tree_template.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'POST api/v1/trees/templates' do
    subject(:do_request) { post '/api/v1/trees/templates', params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:title) { Faker::Lorem.sentence }
    let(:description) { Faker::Lorem.sentence }
    let(:owner) { create(:user) }
    let(:params) do
      {
        tree_template: {
          title: title,
          description: description,
          owner_type: owner.class.name,
          owner_id: owner.id,
        },
      }
    end

    let(:tree_template_policy) do
      instance_double(
        Tree::TemplatePolicy,
        create?: current_user_has_permissions?,
        update?: true,
        destroy?: true,
      )
    end

    before do
      allow(Tree::TemplatePolicy).to receive(:new).and_return(tree_template_policy)
    end

    context 'when current user has permissions' do
      let(:current_user_has_permissions?) { true }

      context 'when the tree template has been saved successfully' do
        let(:expected_tree_template_json) do
          Tree::TemplateSerializer
            .new(Tree::Template.last, { params: { current_user: current_user } }).to_json
        end

        it 'returns 201 HTTP status code' do
          do_request

          expect(response).to be_created
        end

        it 'returns JSON with correct data' do
          do_request

          expect(response.body).to eq expected_tree_template_json
        end

        it 'creates new Tree::Template for owner' do
          do_request

          expect(owner.tree_templates.last).to have_attributes(title: title, description: description)
        end
      end

      context 'when the tree template cannot be saved successfully' do
        let(:title) { nil }

        it_behaves_like 'when the entity is unprocessable'
      end
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end
  end

  describe 'PATCH/PUT api/v1/trees/templates/:id' do
    subject(:do_request) { put "/api/v1/trees/templates/#{tree_template.id}", params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template) { create(:tree_template, owner: owner) }

    let(:owner) { create(:user) }
    let(:new_title) { Faker::Lorem.sentence }
    let(:new_description) { Faker::Lorem.sentence }
    let(:params) do
      {
        tree_template: {
          title: new_title,
          description: new_description,
          ownerId: (owner.id + 1).to_s,
        },
      }
    end

    let(:tree_template_policy) do
      instance_double(
        Tree::TemplatePolicy,
        update?: current_user_has_permissions?,
        destroy?: true,
      )
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(Tree::TemplatePolicy).to receive(:new)
        .with(current_user, tree_template)
        .and_return(tree_template_policy)
    end

    context 'when the tree template has been updated successfully' do
      let(:expected_tree_template_json) do
        Tree::TemplateSerializer
          .new(tree_template.reload, { params: { current_user: current_user } }).to_json
      end

      it 'returns 200 HTTP status code' do
        do_request

        expect(response).to be_ok
      end

      it 'returns JSON with correct data' do
        do_request

        expect(response.body).to eq expected_tree_template_json
      end

      it 'updates the Tree::Template with allowable passed params only' do
        do_request

        expect(tree_template.reload).to have_attributes(
          title: new_title,
          description: new_description,
          owner_id: owner.id,
          owner_type: owner.class.name,
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

    context 'when tree template does not exist' do
      before do
        tree_template.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'DELETE api/v1/trees/templates/:id' do
    subject(:do_request) { delete "/api/v1/trees/templates/#{tree_template.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:tree_template) { create(:tree_template) }

    let(:tree_template_policy) do
      instance_double(Tree::TemplatePolicy, destroy?: current_user_has_permissions?)
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(Tree::TemplatePolicy).to receive(:new)
        .with(current_user, tree_template)
        .and_return(tree_template_policy)
    end

    context 'when the tree template has been destroyed successfully' do
      it 'returns 204 HTTP status code' do
        do_request

        expect(response).to be_no_content
      end

      it 'destroys the tree template' do
        do_request

        expect { tree_template.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the tree template cannot be destroyed successfully' do
      before do
        allow(Tree::Template).to receive(:find).and_return(tree_template)
        allow(tree_template).to receive(:destroy).and_return(false)
      end

      it_behaves_like 'when a bad request'
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when tree template does not exist' do
      before do
        tree_template.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end
end
