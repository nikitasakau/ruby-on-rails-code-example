class Api::V1::Trees::Instances::Nodes::CompletionsController < ApplicationController
  before_action :set_tree_instance_node, only: %i[create destroy]

  def create
    authorize @tree_instance_node, :update?

    if Tree::Instance::Node::Completion::Create.call(tree_instance_node: @tree_instance_node).successful?
      render_json_create
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tree_instance_node, :update?

    if Tree::Instance::Node::Completion::Destroy.call(tree_instance_node: @tree_instance_node).successful?
      render_json_destroy
    else
      render json: { errors: ['SOMETHING_WENT_WRONG'] }, status: :unprocessable_entity
    end
  end

  private

  def render_json_create
    render json: {
      data: Tree::Instance::Nodes::Serialize.call(
        tree_instance: @tree_instance_node.instance,
        current_user: current_user,
      ),
    }
  end

  def render_json_destroy
    render json: {
      data: Tree::Instance::Nodes::Serialize.call(
        tree_instance: @tree_instance_node.instance,
        current_user: current_user,
      ),
    }
  end

  def set_tree_instance_node
    @tree_instance_node = Tree::Instance::Node.find(params[:node_id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
