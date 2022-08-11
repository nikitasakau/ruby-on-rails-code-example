RSpec.describe Api::V1::OrganizationsController do
  describe 'GET api/v1/organizations/:id' do
    subject(:do_request) { get "/api/v1/organizations/#{organization.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:organization) { create(:organization) }

    let(:expected_organization_json) do
      OrganizationSerializer.new(organization, { params: { current_user: current_user } }).to_json
    end

    it 'returns 200 HTTP status code' do
      do_request

      expect(response).to be_successful
    end

    it 'returns JSON with correct data' do
      do_request

      expect(response.body).to eq expected_organization_json
    end

    context 'when the organization does not exist' do
      before do
        organization.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'POST api/v1/organizations' do
    subject(:do_request) { post '/api/v1/organizations', params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:name) { Faker::Lorem.word }
    let(:description) { Faker::Lorem.sentence }
    let(:params) do
      {
        organization: {
          name: name,
          description: description,
        },
      }
    end

    let(:creation_result) { Organization::Create::Result.new(true, created_organization) }

    let(:created_organization) { create(:organization) }

    before do
      allow(Organization::Create).to receive(:call).and_return(creation_result)
    end

    context 'when the organization has been saved successfully' do
      let(:expected_organization_json) do
        OrganizationSerializer
          .new(created_organization, { params: { current_user: current_user } }).to_json
      end

      it 'returns 201 HTTP status code' do
        do_request

        expect(response).to be_created
      end

      it 'returns JSON with correct data' do
        do_request

        expect(response.body).to eq expected_organization_json
      end

      it 'creates a new Organization for the current user' do
        do_request

        expect(Organization::Create).to have_received(:call)
          .with(name: name, description: description, creator: current_user)
      end
    end

    context 'when the organization cannot be saved successfully' do
      let(:creation_result) { Organization::Create::Result.new(false) }

      it_behaves_like 'when the entity is unprocessable'
    end
  end

  describe 'PATCH/PUT api/v1/organizations/:id' do
    subject(:do_request) { put "/api/v1/organizations/#{organization.id}", params: params }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:organization) { create(:organization) }

    let(:new_name) { Faker::Lorem.sentence }
    let(:new_description) { Faker::Lorem.sentence }
    let(:params) do
      {
        organization: {
          name: new_name,
          description: new_description,
        },
      }
    end

    let(:organization_policy) do
      instance_double(
        OrganizationPolicy,
        update?: current_user_has_permissions?,
        destroy?: true,
      )
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(OrganizationPolicy).to receive(:new)
        .with(current_user, organization)
        .and_return(organization_policy)
    end

    context 'when the organization has been updated successfully' do
      let(:expected_organization_json) do
        OrganizationSerializer
          .new(organization.reload, { params: { current_user: current_user } }).to_json
      end

      it 'returns 200 HTTP status code' do
        do_request

        expect(response).to be_ok
      end

      it 'returns JSON with correct data' do
        do_request

        expect(response.body).to eq expected_organization_json
      end

      it 'updates the Organization with allowable passed params only' do
        do_request

        expect(organization.reload).to have_attributes(
          name: new_name,
          description: new_description,
        )
      end
    end

    context 'when the organization cannot be updated successfully' do
      let(:new_name) { nil }

      it_behaves_like 'when the entity is unprocessable'
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when the organization does not exist' do
      before do
        organization.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end

  describe 'DELETE api/v1/organizations/:id' do
    subject(:do_request) { delete "/api/v1/organizations/#{organization.id}" }

    include_context 'with a current user'

    let(:current_user) { create(:user) }

    let(:organization) { create(:organization) }

    let(:organization_policy) do
      instance_double(OrganizationPolicy, destroy?: current_user_has_permissions?)
    end

    let(:current_user_has_permissions?) { true }

    before do
      allow(OrganizationPolicy).to receive(:new)
        .with(current_user, organization)
        .and_return(organization_policy)
    end

    context 'when the organization has been destroyed successfully' do
      it 'returns 204 HTTP status code' do
        do_request

        expect(response).to be_no_content
      end

      it 'destroys the organization' do
        do_request

        expect { organization.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the organization cannot be destroyed successfully' do
      before do
        allow(Organization).to receive(:find).and_return(organization)
        allow(organization).to receive(:destroy).and_return(false)
      end

      it_behaves_like 'when a bad request'
    end

    context 'when current user does not have permissions' do
      let(:current_user_has_permissions?) { false }

      it_behaves_like 'when the user does not have permissions'
    end

    context 'when organization does not exist' do
      before do
        organization.destroy
      end

      it_behaves_like 'when the entity does not exist'
    end
  end
end
