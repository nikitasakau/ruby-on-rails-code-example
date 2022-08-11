class Api::V1::OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show update destroy]

  def show
    render json: OrganizationSerializer.new(
      @organization,
      {
        params: {
          current_user: current_user,
        },
      },
    )
  end

  def create
    @creation_result = create_organization

    if @creation_result.successful?
      render_json_create
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def update
    authorize @organization

    if @organization.update(update_organization_params)
      render json: OrganizationSerializer.new(@organization, { params: { current_user: current_user } })
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @organization

    if @organization.destroy
      head :no_content
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :bad_request
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def create_organization
    Organization::Create.call(
      name: create_organization_params[:name],
      description: create_organization_params[:description],
      creator: current_user,
    )
  end

  def render_json_create
    render json: OrganizationSerializer.new(
      @creation_result.organization,
      {
        params: {
          current_user: current_user,
        },
      },
    ), status: :created
  end

  def create_organization_params
    params.require(:organization).permit(:name, :description)
  end

  def update_organization_params
    params.require(:organization).permit(:name, :description)
  end
end
