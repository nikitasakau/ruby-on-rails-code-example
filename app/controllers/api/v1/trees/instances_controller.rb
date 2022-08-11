class Api::V1::Trees::InstancesController < ApplicationController
  before_action :set_tree_instance, only: %i[show destroy]

  def show
    render json: Tree::InstanceSerializer.new(
      @tree_instance,
      {
        params: {
          current_user: current_user,
        },
      },
    )
  end

  def create
    if new_tree_instance.save
      Tree::Instance::Sync.call(tree_instance: new_tree_instance)

      render_json_create
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tree_instance

    if @tree_instance.destroy
      head :no_content
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :bad_request
    end
  end

  private

  def set_tree_instance
    @tree_instance = Tree::Instance.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def new_tree_instance
    @_new_tree_instance ||= Tree::Instance.new(
      tree_template_id: create_tree_instance_params[:tree_template_id],
      user: current_user,
    )
  end

  def render_json_create
    render json: Tree::InstanceSerializer.new(
      new_tree_instance,
      {
        params: {
          current_user: current_user,
        },
      },
    ), status: :created
  end

  def create_tree_instance_params
    params.require(:tree_instance).permit(:tree_template_id, :user_id)
  end
end
