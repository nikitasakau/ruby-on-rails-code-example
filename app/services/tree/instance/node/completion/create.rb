class Tree::Instance::Node::Completion::Create
  include Callable

  Result = Struct.new(:successful?)

  def initialize(tree_instance_node:)
    @tree_instance_node = tree_instance_node
  end

  def call
    return Result.new(false) if tree_instance_node.blank? || cannot_complete_the_node?

    if tree_instance_node.update(completed_at: Time.now.utc)
      tree_instance_node.children.update(unblocked_at: Time.now.utc)

      return Result.new(true)
    end

    Result.new(false)
  end

  private

  attr_reader :tree_instance_node

  def cannot_complete_the_node?
    tree_instance_node.blocked? || tree_instance_node.completed?
  end
end
