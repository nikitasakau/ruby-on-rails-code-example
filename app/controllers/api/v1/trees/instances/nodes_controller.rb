class Api::V1::Trees::Instances::NodesController < ApplicationController
  before_action :set_tree_instance, only: %i[index]

  def index
    render json: {
      data: Tree::Instance::Nodes::Serialize.call(
        tree_instance: @tree_instance,
        current_user: current_user,
      ),
    }
  end

  private

  def set_tree_instance
    @tree_instance = Tree::Instance.find(params[:instance_id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
