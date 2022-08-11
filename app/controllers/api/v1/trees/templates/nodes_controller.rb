class Api::V1::Trees::Templates::NodesController < ApplicationController
  before_action :set_tree_template, only: %i[index]
  before_action :set_tree_template_node, only: %i[update destroy]

  def index
    render json: {
      data: Tree::Template::Nodes::Serialize.call(
        tree_template: @tree_template,
        current_user: current_user,
      ),
    }
  end

  def create
    authorize new_tree_template_node

    if new_tree_template_node.save
      Tree::Template::Instances::SyncJob
        .perform_later(tree_template_id: new_tree_template_node.tree_template_id)

      render_json_create
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def update
    authorize @tree_template_node

    if @tree_template_node.update(update_tree_template_node_params)
      render_json_update
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tree_template_node

    if @tree_template_node.destroy
      head :no_content
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :bad_request
    end
  end

  private

  def set_tree_template
    @tree_template = Tree::Template.find(params[:template_id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def set_tree_template_node
    @tree_template_node = Tree::Template::Node.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def render_json_create
    render json: Tree::Template::NodeSerializer.new(
      new_tree_template_node,
      {
        params: {
          current_user: current_user,
        },
      },
    ), status: :created
  end

  def render_json_update
    render json: Tree::Template::NodeSerializer.new(
      @tree_template_node,
      {
        params: {
          current_user: current_user,
        },
      },
    )
  end

  def new_tree_template_node
    @_new_tree_template_node ||= Tree::Template::Node.new(
      icon: create_tree_template_node_params[:icon],
      title: create_tree_template_node_params[:title],
      description: create_tree_template_node_params[:description],
      tree_template_id: create_tree_template_node_params[:tree_template_id],
      parent_id: create_tree_template_node_params[:parent_tree_template_node_id],
    )
  end

  def create_tree_template_node_params
    params.require(:tree_template_node).permit(
      :icon,
      :title,
      :description,
      :tree_template_id,
      :parent_tree_template_node_id,
    )
  end

  def update_tree_template_node_params
    params.require(:tree_template_node).permit(
      :icon,
      :title,
      :description,
    )
  end
end
