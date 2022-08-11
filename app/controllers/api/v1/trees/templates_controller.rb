class Api::V1::Trees::TemplatesController < ApplicationController
  before_action :set_tree_template, only: %i[show update destroy]

  def show
    render json: Tree::TemplateSerializer.new(
      @tree_template,
      {
        params: {
          current_user: current_user,
        },
      },
    )
  end

  def create
    authorize new_tree_template

    if new_tree_template.save
      render_json_create
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def update
    authorize @tree_template

    if @tree_template.update(update_tree_template_params)
      render json: Tree::TemplateSerializer.new(@tree_template, { params: { current_user: current_user } })
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tree_template

    if @tree_template.destroy
      head :no_content
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :bad_request
    end
  end

  private

  def set_tree_template
    @tree_template = Tree::Template.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def new_tree_template
    @_new_tree_template ||= Tree::Template.new(
      title: create_tree_template_params[:title],
      description: create_tree_template_params[:description],
      owner_type: create_tree_template_params[:owner_type],
      owner_id: create_tree_template_params[:owner_id],
    )
  end

  def render_json_create
    render json: Tree::TemplateSerializer.new(
      new_tree_template,
      {
        params: {
          current_user: current_user,
        },
      },
    ), status: :created
  end

  def create_tree_template_params
    params.require(:tree_template).permit(:title, :description, :owner_type, :owner_id)
  end

  def update_tree_template_params
    params.require(:tree_template).permit(:title, :description)
  end
end
