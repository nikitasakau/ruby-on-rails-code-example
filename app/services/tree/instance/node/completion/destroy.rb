class Tree::Instance::Node::Completion::Destroy
  include Callable

  Result = Struct.new(:successful?)

  def initialize(tree_instance_node:)
    @tree_instance_node = tree_instance_node
  end

  def call
    return Result.new(false) if tree_instance_node.blank? || cannot_uncomplete_the_node?

    if tree_instance_node.update(completed_at: nil)
      tree_instance_node.descendants.update(unblocked_at: nil, completed_at: nil)

      return Result.new(true)
    end

    Result.new(false)
  end

  private

  attr_reader :tree_instance_node

  def cannot_uncomplete_the_node?
    tree_instance_node.blocked? || !tree_instance_node.completed?
  end
end
